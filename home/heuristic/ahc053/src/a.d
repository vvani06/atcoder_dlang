void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  long N = scan!long;
  long M = scan!long;
  long L = scan!long;
  long R = scan!long;

  long MAX = R - L;

  long[] A = L.repeat(M).array;
  auto unitSize = 27;
  foreach(div, size; zip(
    [2L, 2L^^2, 2L^^3, 2L^^4, 2L^^5, 2L^^6, 2L^^7, 2L^^8, 2L^^9, 2L^^10, 2L^^11, 2L^^12, 2L^^13, 2L^^14, 2L^^15, 2L^^16, 2L^^17, 2L^^18],
    [29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29],
  )) {
    auto uni = MAX / div;
    auto ma = uni + uni / 3;
    auto mi = uni - uni / 4;
    A ~= iota(size).map!(_ => uniform(mi, ma, RND)).array;
  }
  A = A[0..N];
  A.sort!"a > b";

  writefln("%(%s %)", A);
  stdout.flush();

  long[] B = scan!long(M);

  int[] ans = new int[](N);
  long[] diffs = 0L ~ B.dup;
  foreach(bi, b; B.enumerate(1)) {
    long s;
    foreach(ai, a; A.enumerate(0)) {
      if (ans[ai] > 0) continue;

      if (s + a <= b) {
        s += a;
        diffs[bi] -= a;
        ans[ai] = bi;
      }
    }
  }

  foreach(bi, diff; diffs[1..$].enumerate(1)) {
    foreach_reverse(ai, a; A.enumerate(0)) {
      if (ans[ai] > 0) continue;

      if (a - diff < diff) {
        diff -= a;
        ans[ai] = bi;
      }
    }
  }

  // diffs.sort!"abs(a) < abs(b)".deb;
  
  writefln("%(%s %)", ans);
  stdout.flush();
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
