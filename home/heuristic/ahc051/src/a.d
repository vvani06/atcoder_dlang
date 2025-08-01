void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  struct Coord {
    int x, y;
  }

  bool intersect(ref Coord p1, ref Coord p2, ref Coord q1, ref Coord q2) {
    if (max(p1.x, p2.x) < min(q1.x, q2.x) ||
        max(q1.x, q2.x) < min(p1.x, p2.x) ||
        max(p1.y, p2.y) < min(q1.y, q2.y) ||
        max(q1.y, q2.y) < min(p1.y, p2.y))
        return false;

    int sign(int v) {
      return v > 0 ? 1 : v < 0 ? -1 : 0;
    }

    int orientation(ref Coord a, ref Coord b, ref Coord c) {
      return sign((b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x));
    }

    auto o1 = orientation(p1, p2, q1);
    auto o2 = orientation(p1, p2, q2);
    auto o3 = orientation(q1, q2, p1);
    auto o4 = orientation(q1, q2, p2);
    return (o1 * o2 <= 0) && (o3 * o4 <= 0);
  }

  int N = scan!int;
  int M = scan!int;
  int K = scan!int;
  int[][] D = scan!int(2 * N).chunks(2).array;
  int[][] S = scan!int(2 * M).chunks(2).array;
  real[][] P = scan!real(K * N).chunks(N).array;

  writefln("%(%s %)", N.iota);
  writefln("%s", 0);
  foreach(_; 0..M) writefln("%s", -1);
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
