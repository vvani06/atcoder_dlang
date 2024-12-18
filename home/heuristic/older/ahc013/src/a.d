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

  void apply(T)(T[][] grid) {
    swap(grid[sx][sy], grid[ex][ey]);
  }

  string toString() {
    return "%s %s %s %s".format(sx, sy, ex, ey);
  }
}

struct Cluster {
  int type;
  Point[] points;

  this(int type, Point[] points) {
    this.type = type;
    this.points = points;
  }

  Cluster recalc(int[][] grid) {
    auto N = grid.length.to!int;
    auto visited = new bool[][](N, N);
    
    Point[] newPoints;
    foreach(pp; points) {
      if (pp.of(grid) != type) continue;

      newPoints ~= pp;
      for(auto queue = new DList!Point(pp); !queue.empty;) {
        auto p = queue.front;
        queue.removeFront;
        visited[p.x][p.y] = true;
        foreach(dir; DIRS) {
          foreach(delta; 1..N) {
            auto np = p;
            np.x += dir[0] * delta;
            np.y += dir[1] * delta;
            if (!np.valid(N) || np.of(visited)) break;
            if (np.of(grid) == 0) continue;

            if (np.of(grid) == type) {
              queue.insertBack(np);
              newPoints ~= np;
              foreach(d; 1..delta + 1) {
                auto dp = p;
                dp.x += dir[0] * d;
                dp.y += dir[1] * d;
                visited[dp.x][dp.y] = true;
              }
            }
            
            break;
          }
        }
      }

      return Cluster(type, newPoints);
    }

    return Cluster(type, []);
  }

  int score() {
    auto size = points.length.to!int;
    return size * (size - 1) / 2;
  }
}

struct Evaluation {
  Cluster[] clusters;
  int score;

  this(int[][] grid) {
    auto N = grid.length.to!int;
    auto visited = new bool[][](N, N);

    foreach(x; 0..N) foreach(y; 0..N) {
      if (visited[x][y]) continue;

      auto k = grid[x][y];
      if (k == 0 || visited[x][y]) continue;
      visited[x][y] = true;

      auto points = [Point(x, y)];
      for(auto queue = new DList!Point(Point(x, y)); !queue.empty;) {
        auto p = queue.front;
        queue.removeFront;
        foreach(dir; DIRS) {
          foreach(delta; 1..N) {
            auto np = p;
            np.x += dir[0] * delta;
            np.y += dir[1] * delta;
            if (!np.valid(N) || np.of(visited)) break;
            if (np.of(grid) == 0) continue;

            if (np.of(grid) == k) {
              queue.insertBack(np);
              points ~= np;
              foreach(d; 1..delta + 1) {
                auto dp = p;
                dp.x += dir[0] * d;
                dp.y += dir[1] * d;
                visited[dp.x][dp.y] = true;
              }
            }
            
            break;
          }
        }
      }

      auto size = points.length.to!int;
      if (size > 2) {
        clusters ~= Cluster(k, points);
        score += size * (size - 1) / 2;
      }
    }

    clusters.sort!"a.score > b.score";
  }

  Cluster[] top() {
    return clusters[0..min($, 2)];
  }

  int innerCalc(int rank, int score) {
    // return rank*rank*score;
    return rank * score;
  }

  int topScore() {
    int ret;
    foreach(i, c; top) {
      ret += innerCalc(top.length.to!int - i.to!int, c.score);
    }
    return ret;
  }
 
  int topScoreRecalced(int[][] grid) {
    int ret;
    foreach(i, c; top) {
      ret += innerCalc(top.length.to!int - i.to!int, c.recalc(grid).score);
    }
    return ret;
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
  auto rnd = Xorshift(unpredictableSeed);

  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

  Move[][] executeRandomMove() {
    Move[][] moves;
    int rest = K * 100;

    Point[] whites;
    foreach(x; 0..N) foreach(y; 0..N) {
      if (G[x][y] == 0) whites ~= Point(x, y);
    }

    foreach(_; 0..1000) {
      if (rest <= 100) break;
      if (elapsed(2000)) break;

      auto eval = Evaluation(G);
      int maxScore;
      int maxi;
      Move[] maxMoves;
      DList!Move ml;
      void dfs(Point p, Point pre, int t, int i) {
        if (t < 3 && maxScore.chmax(eval.topScoreRecalced(G))) {
          maxMoves = ml.array;
          maxi = i;
        }
        if (t == 0) return;

        static foreach(d; DIRS) {{
          auto np = Point(p.x + d[0], p.y + d[1]);
          if (np.valid(N) && np != pre && np.of(G) != 0) {
            auto move = Move(np, p);
            ml.insertBack(move);
            move.apply(G);
            dfs(np, p, t - 1, i);
            move.apply(G);
            ml.removeBack;
          }
        }}
      }

      whites = whites.randomShuffle(rnd).array;
      foreach(i, p; whites[0..min(100, $)]) dfs(p, p, 3, i.to!int);
      // [maxScore, eval.topScore].deb;
      if (maxScore > eval.topScore) {
        rest -= maxMoves.length;
        moves ~= maxMoves;
        foreach(move; maxMoves) move.apply(G);

        whites[maxi].x = maxMoves[$ - 1].sx;
        whites[maxi].y = maxMoves[$ - 1].sy;
      }
    }
    return moves;
  }

  auto solve() {
    auto init = G.map!"a.dup".array;
    auto randomMoves = executeRandomMove();
    randomMoves.joiner.array.length.deb;
    // if (moves.empty) moves ~= executeSortingMove();
    
    Move[] bestMoves;
    Connection[] bestConnections;
    int bestScore;

    foreach(moveIgnores; 0..randomMoves.length + 1) {
      Move[] moves;
      G = init.map!"a.dup".array;
      foreach(mm; randomMoves[0..$ - moveIgnores]) {
        foreach(m; mm) swap(G[m.sx][m.sy], G[m.ex][m.ey]);
        moves ~= mm;
      }

      Connection[] connections;
      auto globalVisited = new bool[][](N, N);
      auto globalUf = UnionFind(MAX_N * MAX_N);
      int rest = K*100 - moves.length.to!int;
      auto penalty = new int[](MAX_N * MAX_N);

      auto eval = Evaluation(G);
      eval.score.deb;
      foreach(ci, c; eval.clusters) {
        Point bestPoint;
        bestPoint.x = -1;
        Point[Point] bestWalls;
        auto bestSize = c.points.length.to!int;
        for(auto queue = new DList!Point(c.points); !queue.empty;) {
          auto p = queue.front;
          queue.removeFront;
          if (p.of(G) != c.type) bestSize--;
          if (p.of(globalVisited) || p.of(G) != c.type) continue;

          if (bestPoint.x == -1) bestPoint = p;
          foreach(dir; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
            foreach(delta; 1..N) {
              auto np = p;
              np.x += dir[0] * delta;
              np.y += dir[1] * delta;
              if (!np.valid(N) || np.of(globalVisited)) break;

              if (np.of(G) == 0) continue;
              if (np.of(G) != c.type) {
                bestWalls[np] = p;
                break;
              }
            } 
          }
        }

        if (bestPoint.x == -1) continue;

        int bestWallSize;
        Point bestWall;
        foreach(w; bestWalls.keys) {
          auto bk = G[w.x][w.y];
          G[w.x][w.y] = c.type;
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

                if (np.of(G) == c.type) {
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
                if (np.of(G) != c.type) break;
              }
            }
          }

          if (bestWallSize.chmax(wallSize)) bestWall = w;
          G[w.x][w.y] = bk;
        }
        
        // [bestWallSize, bestSize].deb;
        if (bestWallSize > bestSize + 2) {
          G[bestWall.x][bestWall.y] = c.type;
          // globalVisited[bestWall.x][bestWall.y] = true;
          penalty[globalUf.root(bestPoint.toId)]++;
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
              if (!np.valid(N) || np.of(globalVisited)) break;
              if (np.of(G) == 0) continue;

              if (np.of(G) == c.type) {
                if (globalUf.same(p.toId, np.toId)) break;
                if (rest <= 0) break;

                queue.insertBack(np);
                globalUf.unite(p.toId, np.toId);
                connections ~= Connection(p, np);
                rest--;
                foreach(d; 1..delta + 1) {
                  auto dp = p;
                  dp.x += dir[0] * d;
                  dp.y += dir[1] * d;
                  globalVisited[dp.x][dp.y] = true;
                }
              }
              break;
            }
          }
          if (rest <= 0) break;
        }
      }

      if (bestScore.chmax(calcScore(globalUf, penalty))) {
        bestConnections = connections;
        bestMoves = moves;
      }
      if (elapsed(2750)) break;
    }

    bestMoves.length.writeln;
    bestMoves.each!writeln;
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
