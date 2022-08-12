void main() { runSolver(); }

// ----------------------------------------------

enum MAX_N = 50;

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

int calcScore(UnionFind uf) {
  auto sizes = new int[](MAX_N * MAX_N);
  foreach(x; 0..MAX_N) foreach(y; 0..MAX_N) {
    sizes[uf.root(MAX_N * x + y)]++;
  }

  return sizes.map!(s => s*(s - 1) / 2).sum;
}

void problem() {
  auto N = scan!int;
  auto K = scan!int;
  auto G = scan!string(N).map!(s => s.map!(c => c - '0').array).array;

  auto solve() {
    int bestScore;
    Move[] moves;
    Connection[] bestConnections;

    foreach(k; 2..3) {
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
            G[x][y].deb;
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

    foreach(pattern; iota(1, K + 1).permutations) {
      int rest = K*100 - moves.length.to!int;
      Connection[] connections;
      auto uf = UnionFind(MAX_N * MAX_N);
      auto visited = new bool[][](N, N);

      foreach(k; pattern) {
        Point[] starts;
        foreach(x; 0..N) foreach(y; 0..N) {
          auto p = Point(x, y);
          if (p.of(G) == k) starts ~= p;
        }

        for(auto queue = new DList!Point(starts); !queue.empty;) {
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

                rest--;
                uf.unite(p.toId, np.toId);
                connections ~= Connection(p, np);
                foreach(d; 1..delta + 1) {
                  auto dp = p;
                  dp.x += dir[0] * d;
                  dp.y += dir[1] * d;
                  visited[dp.x][dp.y] = true;
                }
                break;
              }

              if (np.of(G) == 0 && !np.of(visited)) continue;
              if (np.of(G) != k) break;
            }
          }
        }
      }

      if (bestScore.chmax(calcScore(uf))) {
        bestConnections = connections;
      }
    }

    moves.length.writeln;
    moves.each!writeln;
    bestConnections.length.writeln;
    bestConnections.each!writeln;
    stderr.writeln(bestScore);
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
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
  enum BORDER = "#==================================";
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct UnionFind {
  int[] parent;

  this(int size) {
    parent.length = size;
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
}
