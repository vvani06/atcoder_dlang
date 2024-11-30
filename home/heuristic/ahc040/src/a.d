void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto RND = Xorshift(0);

  int N = scan!int;
  int T = scan!int;
  int S = scan!int;
  long[][] WH = scan!long(N * 2).chunks(2).array;

  long[] testPack(long threshold) {
    int largest = -1;
    int nextLargest = -1;
    long nextLargestSize;
    long cur;

    N.writeln;
    foreach(i, whb; WH.enumerate(0)) {
      auto wh = whb.dup;
      int rotated;
      if (wh[0] > wh[1] && nextLargestSize < wh[0]) {
        rotated = 1;
        swap(wh[0], wh[1]);
      }

      writefln("%s %s %s %s", i, rotated, "U", largest);
      cur += wh[1];
      if (nextLargestSize.chmax(wh[0])) {
        nextLargest = i;
      }

      if (cur > threshold) {
        largest = nextLargest;
        nextLargest = -1;
        nextLargestSize = cur = 0;
      }
    }
    stdout.flush();
    return scan!long(2);
  }

  long threshold = WH.map!"a.maxElement".sum;
  long bestThreshold;
  long bestScore = long.max;
  foreach(t; 0..T - 1) {
    long th = (threshold * (0.01 + 0.005*t)).to!long;
    long[] wh = testPack(th);
    if (bestScore.chmin(wh.sum)) {
      bestThreshold = th;
    }
  }

  testPack(bestThreshold);
}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
// void deb(T ...)(T t){ debug {  }}
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
  problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
