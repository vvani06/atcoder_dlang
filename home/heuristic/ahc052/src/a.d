void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int M = scan!int;
  int K = scan!int;
  int[][] RC = scan!int(2 * M).chunks(2).array;
  string[] V = scan!string(N);
  string[] H = scan!string(N - 1);

  enum DIRS = "LURD";

  alias Coord = Tuple!(int, "r", int, "c");

  class Grid {
    bool[][] left;
    bool[][] right;
    bool[][] up;
    bool[][] down;

    this(string[] v, string[] h) {
      left = new bool[][](N, N);
      right = new bool[][](N, N);
      foreach(r; 0..N) foreach(c; 0..N - 2) {
        if (v[r][c] == '0') {
          right[r][c] = true;
          left[r][c + 1] = true;
        }
      }
      up = new bool[][](N, N);
      down = new bool[][](N, N);
      foreach(r; 0..N - 2) foreach(c; 0..N) {
        if (h[r][c] == '0') {
          down[r][c] = true;
          up[r + 1][c] = true;
        }
      }
    }

    bool canWalk(Coord coord, int dir) {
      if (dir == 0) return left[coord.r][coord.c];
      if (dir == 1) return up[coord.r][coord.c];
      if (dir == 2) return right[coord.r][coord.c];
      return down[coord.r][coord.c];
    }
  }

  Grid grid = new Grid(V, H);

  foreach(m; 0..M) {
    writefln("%s", K.iota.map!(_ => "LLRRDDUUS".array.choice(RND).to!string).joiner(" "));
  }
  foreach(i; 0..2 * N^^2) {
    writeln(K.iota.choice(RND));
  }
}

// ----------------------------------------------

import std;
import core.bitop;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(lazy T t){ debug { write("# "); writeln(t); }}
void debf(T ...)(lazy T t){ debug { write("# "); writefln(t); }}
// void deb(T ...)(T t){ debug {  }}
T[] divisors(T)(T n) { T[] ret; for (T i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == float) || is(T == double) || is(T == float)) "%.16f".writefln(fn());
  else static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
  else static if (isInputRange!T) {
    static if (!is(string == ElementType!T) && isInputRange!(ElementType!T)) foreach(r; fn()) r.toAnswerString.writeln;
    else foreach(r; fn()) r.writeln;
  }
  else fn().writeln;
}
void runSolver() {
  problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
