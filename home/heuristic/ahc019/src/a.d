void main() { runSolver(); }

// ----------------------------------------------

void problem() {
  enum MAX_D = 14;
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
  }

  struct Requirement {
    bool[][][] front, right;

    this(bool[][] f1, bool[][] r1, bool[][] f2, bool[][] r2) {
      front ~= f1;
      front ~= f2;
      right ~= r1;
      right ~= r2;
    }
  }

  struct State {
   int[MAX_D][MAX_D][MAX_D][2] v;

    this(int d) {
      foreach(i; 0..2) {
        int blocks;
        foreach(x, y, z; XYZ) {
          if (!F[i][y][x] || !R[i][y][z]) continue;

          v[i][x][z][y] = ++blocks;
        }
      }
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
