void main() { runSolver(); }

// ----------------------------------------------

enum SIZE = 10;
enum SIZE2 = SIZE * SIZE;
enum ROT = "FBLR";

class State {
  byte[] p;
  this() { p = new byte[](SIZE2); }
  this(byte[] pp) { p = pp; }

  int idx(int x, int y) { return y * SIZE + x; }

  State rotate(int r) {
    return 
      r == 0 ? rotateFront() :
      r == 1 ? rotateBack() :
      r == 2 ? rotateLeft() : rotateRight();
  }

  State rotateFront() {
    auto r = new byte[](SIZE2);
    foreach(x; 0..SIZE) {
      int t;
      foreach(y; 0..SIZE) {
        if (p[SIZE * y + x] != 0) {
          r[SIZE * t + x] = p[SIZE * y + x];
          t++;
        }
      }
    }
    return new State(r);
  }

  State rotateBack() {
    auto r = new byte[](SIZE2);
    foreach(x; 0..SIZE) {
      int t = SIZE - 1;
      foreach_reverse(y; 0..SIZE) {
        if (p[SIZE * y + x] != 0) {
          r[SIZE * t + x] = p[SIZE * y + x];
          t--;
        }
      }
    }
    return new State(r);
  }

  State rotateLeft() {
    auto r = new byte[](SIZE2);
    foreach(y; 0..SIZE) {
      int t;
      foreach(x; 0..SIZE) {
        if (p[SIZE * y + x] != 0) {
          r[SIZE * y + t] = p[SIZE * y + x];
          t++;
        }
      }
    }
    return new State(r);
  }

  State rotateRight() {
    auto r = new byte[](SIZE2);
    foreach(y; 0..SIZE) {
      int t = SIZE - 1;
      foreach_reverse(x; 0..SIZE) {
        if (p[SIZE * y + x] != 0) {
          r[SIZE * y + t] = p[SIZE * y + x];
          t--;
        }
      }
    }
    return new State(r);
  }

  void store(byte to, byte type) {
    int dec = -1;
    foreach(i; 0..SIZE2) {
      if (p[i] != 0) {
        dec++;
      } else if (i - dec == to) {
        p[i] = type;
        // [to, i].deb;
        break;
      }
    }
  }

  long calcScore() {
    long score;
    foreach(type; 1..4) {
      auto visited = new bool[](SIZE2);
      foreach(x; 0..SIZE) foreach(y; 0..SIZE) {
        if (visited[idx(x, y)] || p[idx(x, y)] != type) continue;

        long count;
        void dfs(int x, int y) {
          if (visited[idx(x, y)]) return;
          visited[idx(x, y)] = true;

          if (p[idx(x, y)] == type) count++;
          foreach(d; [1, 0, -1, 0].zip([0, 1, 0, -1])) {
            const dx = x + d[0];
            const dy = y + d[1];
            if (min(dx, dy) < 0 || max(dx, dy) >= SIZE) continue;

            if (p[idx(dx, dy)] == 0 || p[idx(dx, dy)] == type) {
              dfs(dx, dy);
            }
          }
        }

        dfs(x, y);
        score += count ^^ 2;
      }
    }

    return 10^^6 * score;
  }
}

void problem() {
  auto F = scan!byte(SIZE2);
  auto fc = new int[](4);
  foreach(f; F) fc[f]++;

  auto fcs = fc.enumerate(0).array.sort!"a[1] > b[1]";
  auto rank = new int[](4);
  foreach(i; 0..3) rank[fcs[i][0]] = i; 

  const diff = fc[1..$].maxElement - fc[1..$].minElement;
  auto table = [0, 1, 1];
  
  auto solve() {
    auto state = new State();
    int cont;
    foreach(i; 0..SIZE2) {
      const p = scan!byte;
      const cur = F[i];
      state.store(p, cur);

      int rot;
      if (i < SIZE2 - 1) {
        const next = F[i + 1];

        if (i < 78 - diff/4 || rank[next] == 0) {
          rot = table[rank[next]];
        } else {
          long bestExp;
          foreach(r; 0..4) {
            auto exState = state.rotate(r);
            long exp;
            foreach(ti; 1..SIZE2 - i) {
              exState.store(ti.to!byte, next);
              exp += exState.calcScore;
              exState.store(ti.to!byte, 0);
            }
            if (bestExp.chmax(exp)) rot = r;
          }
        }
      }

      state = state.rotate(rot);
      ROT[rot].writeln;
      stdout.flush();
    }

    // state.p.chunks(SIZE).each!deb;
    const score = state.calcScore() / fc.map!"a ^^ 2".sum;
    stderr.writeln(score);
  }

  solve();
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
