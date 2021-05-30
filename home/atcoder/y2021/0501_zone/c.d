void main() {
  debug {
    "==================================".writeln;
    while(true) {
      auto bench =  benchmark!problem(1);
      "<<< Process time: %s >>>".writefln(bench[0]);
      "==================================".writeln;
    }
  } else {
    problem();
  }
}

void problem() {
  auto N = scan!long;
  auto M = scan!long(5 * N).chunks(5).array;

  auto solve() {
    bool isValid(long x) {
      enum long[] bitNums = [1, 2, 4, 8, 16];
      bool[long] membersAsBits;

      foreach(m; M) {
        long mb;
        foreach(b; 0..5) {
          if (m[b] >= x) mb += bitNums[b];
        }
        membersAsBits[mb] = true;
      }

      auto bits = membersAsBits.keys;
      if (bits.length == 0) return false;
      if (bits.length == 1) return bits[0] == 0b11111;
      if (bits.length == 2) return (bits[0] | bits[1]) == 0b11111;

      foreach(bitsCombinations; membersAsBits.keys.combinations(3)) {
        long sum;
        foreach(b; bitsCombinations) {
          sum |= b;
          if (sum == 0b11111) return true;
        }
      }

      return false;
    }
    
    return binarySearch((long x) => x, &isValid, 1, 10^^9 + 1);
  }

  static if (is(ReturnType!(solve) == void)) solve(); else solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

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


struct CombinationRange(T) {
  private {
    int combinationSize;
    int elementSize;
    int pointer;
    int[] cursor;
    T[] elements;
    T[] current;
  }

  public:

  this(T[] t, int combinationSize) {
    this.combinationSize = combinationSize;
    this.elementSize = cast(int)t.length;
    pointer = combinationSize - 1;
    cursor = new int[combinationSize];
    current = new T[combinationSize];
    elements = t.dup;
    foreach(i; 0..combinationSize) {
      cursor[i] = i;
      current[i] = elements[i];
    }
  }

  @property T[] front() {
    return current;
  }

  void popFront() {
    if (pointer == -1) return;

    if (cursor[pointer] == elementSize + pointer - combinationSize) {
      pointer--;
      popFront();
      if (pointer < 0) return;

      pointer++;
      cursor[pointer] = cursor[pointer - 1];
      current[pointer] = elements[cursor[pointer]];
    }

    cursor[pointer]++;
    current[pointer] = elements[cursor[pointer]];
  }

  bool empty() {
    return pointer == -1;
  }
}
CombinationRange!T combinations(T)(T[] t, int size) { return CombinationRange!T(t, size); }
