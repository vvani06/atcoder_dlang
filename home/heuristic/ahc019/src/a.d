void main() { runSolver(); }

// ----------------------------------------------

enum MAX_D = 14;
alias MATRIX = int[MAX_D][MAX_D][MAX_D];
// alias MATRIX = int[][][];

void problem() {
  auto D = scan!int;
  auto Diota = D.iota;
  auto XYZ = cartesianProduct(Diota, Diota, Diota);
  auto F1 = scan!string(D).map!(s => s.map!"a == '1'".array).array;
  auto R1 = scan!string(D).map!(s => s.map!"a == '1'".array).array;
  auto F2 = scan!string(D).map!(s => s.map!"a == '1'".array).array;
  auto R2 = scan!string(D).map!(s => s.map!"a == '1'".array).array;
  auto F = [F1, F2];
  auto R = [R1, R2];

  struct Coord {
    int x, y, z;

    Coord add(Coord other) {
      return Coord(x + other.x, y + other.y, z + other.z);
    }
    Coord sub(Coord other) {
      return Coord(x - other.x, y - other.y, z - other.z);
    }

    int min() { return std.algorithm.comparison.min(x, y, z); }
    int max() { return std.algorithm.comparison.max(x, y, z); }
    bool valid() { return min >= 0 && max < D; }

    int of(MATRIX matrix) { return matrix[x][z][y]; }

    enum AX = Coord(1, 0, 0);
    enum AY = Coord(0, 1, 0);
    enum AZ = Coord(0, 0, 1);
    enum BX = Coord(-1, 0, 0);
    enum BY = Coord(0, -1, 0);
    enum BZ = Coord(0, 0, -1);
    enum MOVES = [AX, AY, AZ, BX, BY, BZ];
  }

  struct State {
   MATRIX[2] v;
   int[100000] size;
   int vid;

    void update(int i, Coord c, int value) {
      v[i][c.x][c.z][c.y] = value;
    }

    this(int d) {
      // v = new int[][][][](2, d, d, d);

      size[0] = 100000;
      foreach(i; 0..2) {
        foreach(x, y, z; XYZ) {
          if (!F[i][y][x] || !R[i][y][z]) continue;

          v[i][x][z][y] = ++vid;
          size[vid] = 1;
        }
      }
    }

    int merge(Coord from1, Coord from2, bool dryrun) {
      if (size[from1.of(v[0])] != 1 || size[from2.of(v[1])] != 1) return 0;

      MATRIX visited;
      visited[from1.x][from1.z][from1.y] = 1;
      const base = from1.of(v[0]);
      if (!dryrun) update(1, from2, base);

      int merged;
      void dfs(Coord cur, Coord pre) {
        if (cur.of(visited) || !cur.valid) return;
        visited[cur.x][cur.z][cur.y] = 1;

        auto diff = cur.sub(from1);
        auto cur2 = from2.add(diff);
        if (!cur2.valid) return;

        // 体積1のブロックだけを侵食する
        if (size[cur.of(v[0])] != 1) return;
        if (size[cur2.of(v[1])] != 1) return;

        // [cur, cur2].deb;
        // [cur.of(v[0]), cur2.of(v[1])].deb;

        // ブロックのマージ
        merged++;
        if (!dryrun) {
          update(0, cur, base);
          update(1, cur2, base);
          size[base]++;
        }

        foreach(d; Coord.MOVES) {
          auto next = cur.add(d);
          if (next != pre && next.valid) {
            dfs(next, cur);
          }
        }
      }
      
      foreach(d; Coord.MOVES) {
        auto next = from1.add(d);
        if (next.valid) dfs(next, from1);
      }

      return merged;
    }

    string toString() {
      string[] ret;

      int[int] conv; {
        auto using = new int[](0);
        foreach(i; 0..2) foreach(x, y, z; XYZ) {
          using ~= v[i][x][z][y];
        }
        auto uni = using.sort.uniq;
        foreach(u; uni.enumerate(0)) conv[u[1]] = u[0];
      }

      ret ~= (conv.length - 1).to!string;
      foreach(i; 0..2) {
        foreach(x; 0..D) {
          int[] arr;
          foreach(z; 0..D) foreach(y; 0..D) arr ~= conv[v[i][x][z][y]];
          ret ~= "%(%03d %)".format(arr);
        }
      }
      return ret.joiner("\n").to!string;
    }
  }

  auto solve() {
    auto state = State(D);

    foreach(x1, y1, z1; XYZ) {
      auto from = Coord(x1, y1, z1);
      Coord bestCoord;
      int best;
      foreach(x2, y2, z2; XYZ) {
        auto merged = state.merge(from, Coord(x2, y2, z2), true);
        if (best.chmax(merged)) {
          bestCoord = Coord(x2, y2, z2);
        }
      }
      
      if (best > 0) {
        best.deb;
        state.merge(from, bestCoord, false);
      }
    }

    state.writeln;
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
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; break; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
