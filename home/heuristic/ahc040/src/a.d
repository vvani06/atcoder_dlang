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

  long baseHeight = WH.map!"a[0] * a[1]".sum.to!real.sqrt.to!long;
  baseHeight.deb;

  class Rect {
    int rectId;
    int rotated;
    int baseRectId;

    this(int id, int r, int b) {
      rectId = id;
      rotated = r;
      baseRectId = b;
    }

    long w() { return WH[rectId][rotated]; }
    long h() { return WH[rectId][1 ^ rotated]; }
    long min() { return WH[rectId].minElement; }
    long max() { return WH[rectId].maxElement; }

    int rotate() { return rotated = rotated ^ 1; }

    string toOutput() {
      return format("%s %s %s %s", rectId, rotated, "L", baseRectId);
    }
  }

  long[] testPack(long threshold) {
    int pre = -1;

    N.writeln;
    Rect[] queue;
    long width;
    
    void resetColumn() {
      foreach(qr; queue) writeln(qr.toOutput());
      width = 0;
      queue.length = 0;  
    }
    
    foreach(i, whb; WH.enumerate(0)) {
      auto rect = new Rect(i, 0, queue.empty ? -1 : queue.back.rectId);
      width = max(width, rect.min());
      queue ~= rect;

      long height;
      foreach(ref qr; queue) {
        if (abs(qr.w - width) > abs(qr.h - width)) qr.rotate();
        height += qr.h;
      }

      if (height >= threshold) {
        resetColumn();
      }
    }

    resetColumn();
    stdout.flush();
    return scan!long(2);
  }

  long threshold = WH.map!"a.maxElement".sum;
  long bestThreshold;
  long bestScore = long.max;
  int tried;

  long stepSize = baseHeight * 100 / T / 200;
  while(tried < T - 1) {
    foreach(d; [-1, 1]) {
      if (tried >= T - 1) break;

      long th = baseHeight + d*stepSize*(tried/2);
      long[] wh = testPack(th);
      if (bestScore.chmin(wh.sum)) {
        bestThreshold = th;
      }
      tried++;
      if (tried == 1) break;
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
