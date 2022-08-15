void main() { runSolver(); }

// ----------------------------------------------

enum MAX_N = 50;
enum DIRS = zip([-1, 0, 1, 0], [0, -1, 0, 1]).array;

struct Point {
  int x, y;

  T of(T)(T[][] t) { return t[x][y]; }
  bool valid(int border) { return min(x, y) >= 0 && max(x, y) < border; }
  int toId() { return MAX_N * x + y; }
}

struct Connection {
  int sx, sy, ex, ey;

  this(int sx, int sy, int ex, int ey) {
    this.sx = sx;
    this.sy = sy;
    this.ex = ex;
    this.ey = ey;
  }

  this(Point f, Point t) {
    this(f.x, f.y, t.x, t.y);
  }

  string toString() {
    return "%s %s %s %s".format(sx, sy, ex, ey);
  }
}

struct Move {
  int sx, sy, ex, ey;

  this(int sx, int sy, int ex, int ey) {
    this.sx = sx;
    this.sy = sy;
    this.ex = ex;
    this.ey = ey;
  }

  this(Point f, Point t) {
    this(f.x, f.y, t.x, t.y);
  }

  string toString() {
    return "%s %s %s %s".format(sx, sy, ex, ey);
  }
}

int calcScore(UnionFind uf, int[] penalty) {
  auto n = MAX_N * MAX_N;
  auto sizes = new int[](n);
  foreach(i; 0..n) sizes[i] -= penalty[i];
  foreach(x; 0..MAX_N) foreach(y; 0..MAX_N) {
    sizes[uf.root(MAX_N * x + y)]++;
  }

  return n.iota.map!(i => sizes[i]*(sizes[i] - 1) / 2 - penalty[i] * sizes[i]).sum;
}

void problem() {
  auto StartTime = MonoTime.currTime();
  auto N = scan!int;
  auto K = scan!int;
  auto G = scan!string(N).map!(s => s.map!(c => (c - '0').to!int).array).array;

  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

  int calcSimpleScore(int[][] g) {
    int ret;
    auto visited = new bool[][](N, N);
    auto uf = UnionFind(MAX_N * MAX_N);

    foreach(x; 0..N) foreach(y; 0..N) {
      if (visited[x][y]) continue;

      auto k = g[x][y];
      if (k == 0 || visited[x][y]) continue;
      visited[x][y] = true;

      int size = 1;
      for(auto queue = new DList!Point(Point(x, y)); !queue.empty;) {
        auto p = queue.front;
        queue.removeFront;
        foreach(dir; DIRS) {
          foreach(delta; 1..N) {
            auto np = p;
            np.x += dir[0] * delta;
            np.y += dir[1] * delta;
            if (!np.valid(N)) break;

            if (np.of(G) == k) {
              if (uf.same(p.toId, np.toId)) break;

              queue.insertBack(np);
              uf.unite(p.toId, np.toId);
              size++;
              foreach(d; 1..delta + 1) {
                auto dp = p;
                dp.x += dir[0] * d;
                dp.y += dir[1] * d;
                visited[dp.x][dp.y] = true;
              }
              break;
            }

            if (np.of(G) == 0) if (np.of(visited)) break; else continue;
            if (np.of(G) != k) break;
          }
        }
      }

      ret += size * (size  - 1) / 2;
    }
    return ret;
  }

  Move[] executeSortingMove() {
    Move[] moves;

    foreach(k; 1..K + 1) {
      auto perX = new int[][](N, 0);
      foreach(x; 0..N) foreach(y; 0..N) {
        if (G[x][y] == k) perX[x] ~= y;
      }
      foreach(x, arr; perX.enumerate(0).array.sort!"a[1].length < b[1].length") {
        long up = x == 0 ? -1 : perX[x - 1].length;
        long down = x == N - 1 ? -1 : perX[x + 1].length;
        if (up < arr.length && down < arr.length) break;

        foreach(y; arr) {
          if (up >= down && G[x - 1][y] == 0) {
            moves ~= Move(x, y, x-1, y);
            swap(G[x][y], G[x - 1][y]);
          } else if (x < N - 1 && G[x + 1][y] == 0) {
            moves ~= Move(x, y, x+1, y);
            swap(G[x][y], G[x + 1][y]);
          }
        }
      }

      auto perY = new int[][](N, 0);
      foreach(x; 0..N) foreach(y; 0..N) {
        if (G[x][y] == k) perY[y] ~= x;
      }
      foreach(y, arr; perY.enumerate(0).array.sort!"a[1].length < b[1].length") {
        long up = y == 0 ? -1 : perY[y - 1].length;
        long down = y == N - 1 ? -1 : perY[y + 1].length;
        if (up < arr.length && down < arr.length) break;

        foreach(x; arr) {
          if (up >= down && G[x][y - 1] == 0) {
            moves ~= Move(x, y, x, y - 1);
            swap(G[x][y], G[x][y - 1]);
          } else if (y < N - 1 && G[x][y + 1] == 0) {
            moves ~= Move(x, y, x, y + 1);
            swap(G[x][y], G[x][y + 1]);
          }
        }
      }
    }

    return moves;
  }

  Move[] executeRandomMove() {
    Move[] moves;
    // if (G.map!(g => g.count(0)).sum > N*N / 10) return moves;

    foreach_reverse(times; 0..500) {
      if (moves.length >= K*50) break;
      if (elapsed(2000)) break;

      Point[] whites;
      foreach(x; 0..N) foreach(y; 0..N) {
        if (G[x][y] == 0) whites ~= Point(x, y);
      }

      int maxScore;
      Move[] maxMoves;
      DList!Move ml;
      void dfs(Point p, Point pre, int t) {
        if (maxScore.chmax(calcSimpleScore(G))) maxMoves = ml.array;
        if (t == 0) return;

        foreach(d; DIRS) {
          auto np = Point(p.x + d[0], p.y + d[1]);
          if (!np.valid(N) || np == pre || np.of(G) == 0) continue;

          ml.insertBack(Move(np, p));
          swap(G[p.x][p.y], G[np.x][np.y]);
          dfs(np, p, t - 1);
          swap(G[p.x][p.y], G[np.x][np.y]);
          ml.removeBack;
        }
      }
      foreach(p; whites.randomShuffle[0..min(120, $)]) {
        dfs(p, p, 3);
      }
      if (calcSimpleScore(G) < maxScore) {
        moves ~= maxMoves;
        foreach(mm; maxMoves) swap(G[mm.sx][mm.sy], G[mm.ex][mm.ey]);
        // maxScore.deb;
      } else break;
    }
    moves.length.deb;
    return moves;
  }

  auto solve() {
    auto moves = executeRandomMove();
    if (moves.empty) moves ~= executeSortingMove();
    calcSimpleScore(G).deb;
    
    Connection[] bestConnections;
    auto globalVisited = new bool[][](N, N);
    auto globalUf = UnionFind(MAX_N * MAX_N);
    int rest = K*100 - moves.length.to!int;
    auto penalty = new int[](MAX_N * MAX_N);

    while(rest > 0) {
      int bestSize;
      Point bestPoint;
      Point[Point] bestWalls;
      foreach(x; 0..N) foreach(y; 0..N) {
        if (G[x][y] == 0 || globalVisited[x][y]) continue;

        Point[Point] walls;
        auto k = G[x][y];
        auto visited = globalVisited.map!"a.dup".array;
        auto uf = globalUf.dup;
        int size;
        for(auto queue = new DList!Point(Point(x, y)); !queue.empty;) {
          auto p = queue.front;
          queue.removeFront;
          foreach(dir; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
            foreach(delta; 1..N) {
              auto np = p;
              np.x += dir[0] * delta;
              np.y += dir[1] * delta;
              if (!np.valid(N)) break;

              if (np.of(G) == k) {
                if (uf.same(p.toId, np.toId)) break;
                if (rest <= 0) break;

                queue.insertBack(np);
                uf.unite(p.toId, np.toId);
                size++;
                foreach(d; 1..delta + 1) {
                  auto dp = p;
                  dp.x += dir[0] * d;
                  dp.y += dir[1] * d;
                  visited[dp.x][dp.y] = true;
                }
                break;
              }

              if (np.of(G) == 0) if (np.of(visited)) break; else continue;
              if (np.of(G) != k) {
                if (!np.of(visited)) walls[np] = p;
                break;
              }
            }
          }
        }

        if (bestSize.chmax(size)) {
          bestPoint = Point(x, y);
          bestWalls = walls;
        }
      }

      if (bestSize <= 1) break;

      auto k = bestPoint.of(G);
      int bestWallSize;
      Point bestWall;
      foreach(w; bestWalls.keys) {
        auto bk = G[w.x][w.y];
        G[w.x][w.y] = k;
        auto visited = globalVisited.map!"a.dup".array;
        auto uf = globalUf.dup;
        int wallSize;
        for(auto queue = new DList!Point(bestPoint); !queue.empty;) {
          auto p = queue.front;
          queue.removeFront;
          foreach(dir; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
            foreach(delta; 1..N) {
              auto np = p;
              np.x += dir[0] * delta;
              np.y += dir[1] * delta;
              if (!np.valid(N)) break;

              if (np.of(G) == k) {
                if (uf.same(p.toId, np.toId)) break;

                queue.insertBack(np);
                uf.unite(p.toId, np.toId);
                wallSize++;
                foreach(d; 1..delta + 1) {
                  auto dp = p;
                  dp.x += dir[0] * d;
                  dp.y += dir[1] * d;
                  visited[dp.x][dp.y] = true;
                }
                break;
              }

              if (np.of(G) == 0) if (np.of(visited)) break; else continue;
              if (np.of(G) != k) break;
            }
          }
        }

        if (bestWallSize.chmax(wallSize)) bestWall = w;
        G[w.x][w.y] = bk;
      }
      
      if (bestWallSize > bestSize + 3) {
        // [bestPoint, bestWall].deb;
        // bestWall.of(globalVisited).deb;
        G[bestWall.x][bestWall.y] = k;
        globalVisited[bestWall.x][bestWall.y] = true;
      } else bestWallSize = 0;

      globalVisited[bestPoint.x][bestPoint.y] = true;
      for(auto queue = new DList!Point(bestPoint); !queue.empty;) {
        auto p = queue.front;
        queue.removeFront;
        foreach(dir; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
          foreach(delta; 1..N) {
            auto np = p;
            np.x += dir[0] * delta;
            np.y += dir[1] * delta;
            if (!np.valid(N)) break;

            if (np.of(G) == k) {
              if (globalUf.same(p.toId, np.toId)) break;
              if (rest <= 0) break;

              queue.insertBack(np);
              globalUf.unite(p.toId, np.toId);
              bestConnections ~= Connection(p, np);
              rest--;
              foreach(d; 1..delta + 1) {
                auto dp = p;
                dp.x += dir[0] * d;
                dp.y += dir[1] * d;
                globalVisited[dp.x][dp.y] = true;
              }
              break;
            }

            if (np.of(G) == 0) if (np.of(globalVisited)) break; else continue;
            if (np.of(G) != k) break;
          }
        }
      }

      if (bestWallSize > 0) penalty[globalUf.root(bestPoint.toId)]++;
    }

    auto bestScore = calcScore(globalUf, penalty);

    moves.length.writeln;
    moves.each!writeln;
    bestConnections.length.writeln;
    bestConnections.each!writeln;
    stderr.writeln(bestScore);
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
T[] divisors(T)(T n) { T[] ret; for (T i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == float) || is(T == double) || is(T == real)) "%.16f".writefln(fn());
  else static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
  else static if (isInputRange!T) {
    static if (!is(string == ElementType!T) && isInputRange!(ElementType!T)) foreach(r; fn()) r.toAnswerString.writeln;
    else foreach(r; fn()) r.writeln;
  }
  else fn().writeln;
}
void runSolver() {
  static import std.datetime.stopwatch;
  enum BORDER = "#==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct UnionFind {
  int[] parent;
  int[] option;

  this(int size) {
    parent.length = size;
    option.length = size;
    foreach(i; 0..size) parent[i] = i;
  }

  int root(int x) {
    if (parent[x] == x) return x;
    return parent[x] = root(parent[x]);
  }

  int unite(int x, int y) {
    int rootX = root(x);
    int rootY = root(y);

    if (rootX == rootY) return rootY;
    return parent[rootX] = rootY;
  }

  bool same(int x, int y) {
    int rootX = root(x);
    int rootY = root(y);

    return rootX == rootY;
  }

  UnionFind dup() {
    UnionFind d = UnionFind(parent.length.to!int);
    d.parent = parent.dup;
    d.option = option.dup;
    return d;
  }
}
