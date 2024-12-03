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

  bool isOverWidth(long threshold) {
    int largest = -1;
    long ret, cur, curWidth;

    foreach(i, whb; WH.enumerate(0)) {
      auto wh = whb.dup;
      if (wh[0] > wh[1] && curWidth < wh[0]) swap(wh[0], wh[1]);

      if (cur > threshold) {
        ret += curWidth;
        curWidth = cur = 0;
      }
      cur += wh[1];
      curWidth = max(curWidth, wh[0]);
    }
    return threshold >= ret + curWidth;
  }

  long bestWidth = binarySearch(&isOverWidth, WH.map!"a.maxElement".sum, 0);
  bestWidth.deb;

  long[] testPack(long threshold) {
    int largest = -1;
    long cur, curWidth;

    N.writeln;
    foreach(i, whb; WH.enumerate(0)) {
      auto wh = whb.dup;
      int rotated;
      if (wh[0] > wh[1] && curWidth < wh[0]) {
        rotated = 1;
        swap(wh[0], wh[1]);
      }

      largest = i - 1;
      if (cur > threshold) {
        largest = -1;
        curWidth = cur = 0;
      }
      
      writefln("%s %s %s %s", i, rotated, "L", largest);
      cur += wh[1];
      curWidth = max(curWidth, wh[0]);
    }
    stdout.flush();
    return scan!long(2);
  }

  long threshold = WH.map!"a.maxElement".sum;
  long bestThreshold;
  long bestScore = long.max;
  int tried;

  long stepSize = bestWidth / 200;
  while(tried < T - 1) {
    foreach(d; [-1, 1]) {
      if (tried >= T - 1) break;

      long th = bestWidth + d*stepSize*(tried/2);
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

K binarySearch(K)(bool delegate(K) cond, K l, K r) { return binarySearch((K k) => k, cond, l, r); }
T binarySearch(T, K)(K delegate(T) fn, bool delegate(K) cond, T l, T r) {
  auto ok = l;
  auto ng = r;
  const T TWO = 2;
 
  bool again() {
    static if (is(T == float) || is(T == double) || is(T == real)) {
      return !ng.approxEqual(ok, 1e-08, 1e-08);
    } else {
      return abs(ng - ok) > 1;
    }
  }
 
  while(again()) {
    const half = (ng + ok) / TWO;
    const halfValue = fn(half);
 
    if (cond(halfValue)) {
      ok = half;
    } else {
      ng = half;
    }
  }
 
  return ok;
}

