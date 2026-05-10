void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto LR = scan!int(2 * M).chunks(2).array;
  auto Q = scan!int;
  auto ST = iota(Q).map!(i => tuple(i, scan!int, scan!int)).array;

  auto solve() {
    int[][int] leftsArray, rightsArray;
    auto slideR = new int[](0).redBlackTree!true;
    foreach(l, r; LR.asTuples!2) {
      leftsArray[l] ~= r;
      rightsArray[r] ~= l;
      slideR.insert(r);
    }
    
    auto lefts = assocArray(leftsArray.keys, leftsArray.values.map!(a => a.redBlackTree!true));
    auto rights = assocArray(rightsArray.keys, rightsArray.values.map!(a => a.redBlackTree!true));

    auto ls = lefts.keys.redBlackTree;
    bool[] ans = new bool[](Q);
    foreach(qi, s, t; ST.multiSort!("a[1] < b[1]", "a[2] < b[2]").asTuples!3) {
      while(!ls.empty && ls.front < s) {
        foreach(r; lefts[ls.front]) slideR.removeKey(r);
        ls.removeFront();
      }

      // [[[qi, s, t]]].deb;
      if (!(s in lefts) || !(t in rights)) continue;

      auto lc = lefts[s].lowerBound(t + 1);
      if (lc.empty) continue;

      auto lr = lc.back;
      rights[lr].removeKey(s);
      slideR.removeKey(lr);
      
      auto rc = rights[t].upperBound(s - 1);
      if ((!rc.empty && (rc.front <= lr + 1)) || (t == lr && !slideR.lowerBound(t + 1).empty)) {
        ans[qi] = true;
      }

      rights[lr].insert(s);
      slideR.insert(lr);
    }

    foreach(a; ans) writeln(asAnswer(a));
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
T[] compress(T)(T[] arr, T origin = T.init) { T[T] indecies; arr.dup.sort.uniq.enumerate(origin).each!((i, t) => indecies[t] = i); return arr.map!(t => indecies[t]).array; }
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
struct ModInt(uint MD) if (MD < int.max) {ulong v;this(string v) {this(v.to!long);}this(int v) {this(long(v));}this(long v) {this.v = (v%MD+MD)%MD;}void opAssign(long t) {v = (t%MD+MD)%MD;}static auto normS(ulong x) {return (x<MD)?x:x-MD;}static auto make(ulong x) {ModInt m; m.v = x; return m;}auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r.v));}auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r.v));}auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r.v%MD).to!ulong);}auto opBinary(string op:"^^", T)(T r) const {long x=v;long y=1;while(r){if(r%2==1)y=(y*x)%MD;x=x^^2%MD;r/=2;} return make(y);}auto opBinary(string op:"/")(ModInt r) const {return this*memoize!inv(r);}static ModInt inv(ModInt x) {return x^^(MD-2);}string toString() const {return v.to!string;}auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}}
alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);
string asAnswer(T ...)(T t) {
  string ret;
  foreach(i, a; t) {
    if (i > 0) ret ~= "\n";
    alias A = typeof(a);
    static if (isIterable!A && !is(A == string)) {
      string[] rets;
      foreach(b; a) rets ~= asAnswer(b);
      static if (isInputRange!A) ret ~= rets.joiner(" ").to!string; else ret ~= rets.joiner("\n").to!string; 
    } else {
      static if (is(A == float) || is(A == double) || is(A == real)) ret ~= "%.16f".format(a);
      else static if (is(A == bool)) ret ~= YESNO[a]; else ret ~= "%s".format(a);
    }
  }
  return ret;
}
void deb(T ...)(T t){ debug t.writeln; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
  else asAnswer(fn()).writeln;
}
void runSolver(bool multiCase = false) {
  static import std.datetime.stopwatch;
  debug { if (multiCase) writeln("! Run as multi-case"); }
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(multiCase ? scan!int : 1)); BORDER.writeln; } }
  else foreach(_; 0..multiCase ? scan!int : 1) problem();
}

enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}

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

enum TernarySearchTarget { Min, Max }
Tuple!(T, K) ternarySearch(T, K)(K delegate(T) fn, T l, T r, TernarySearchTarget target = TernarySearchTarget.Min) {
  auto low = l;
  auto high = r;
  const T THREE = 3;
 
  bool again() {
    static if (is(T == float) || is(T == double) || is(T == real)) {
      return !high.approxEqual(low, 1e-08, 1e-08);
    } else {
      return low != high;
    }
  }

  auto compare = (K a, K b) => target == TernarySearchTarget.Min ? a > b : a < b;
  while(again()) {
    const v1 = (low * 2 + high) / THREE;
    const v2 = (low + high * 2) / THREE;
 
    if (compare(fn(v1), fn(v2))) {
      low = v1 == low ? v2 : v1;
    } else {
      high = v2 == high ? v1 : v2;
    }
  }
 
  return tuple(low, fn(low));
}
