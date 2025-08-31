void main() { runSolver(); }

void problem() {
  alias Coord = Tuple!(long, "r", long, "c");
  auto T = Coord(scan!long, scan!long);
  auto A = Coord(scan!long, scan!long);
  auto N = scan!long;
  auto M = scan!int;
  auto L = scan!int;
  alias Operation = Tuple!(dchar, "op", long, "step");
  auto OT = M.iota.map!(_ => Operation(scan!dchar, scan!long)).array;
  auto OA = L.iota.map!(_ => Operation(scan!dchar, scan!long)).array;

  Coord apply(Coord coord, dchar op, long step) {
    auto r = coord.r;
    auto c = coord.c;
    if (op == 'L') c -= step;
    if (op == 'U') r -= step;
    if (op == 'R') c += step;
    if (op == 'D') r += step;
    return Coord(r, c);
  }

  bool crossed(long a, long b) {
    return (a > 0 && b < 0) || (a < 0 && b > 0);
  }

  auto solve() {
    int indexT, indexA;
    long moved, ans;
    while(true) {
      long step = min(OT[indexT].step, OA[indexA].step);
      auto mT = OT[indexT].op;
      auto mA = OA[indexA].op;
      // deb([mT,':',mA], [step]);

      auto nextT = apply(T, mT, step);
      auto nextA = apply(A, mA, step);

      if (T == A && mT == mA) {
        ans += step;
      } else if (T.r == A.r && nextT.r == nextA.r) {
        long bef = T.c - A.c;
        long aft = nextT.c - nextA.c;
        if ((crossed(bef, aft) && (T.c - A.c) % 2 == 0) || nextT == nextA) {
          ans++;
        }
      } else if (T.c == A.c && nextT.c == nextA.c) {
        long bef = T.r - A.r;
        long aft = nextT.r - nextA.r;
        if ((crossed(bef, aft) && (T.r - A.r) % 2 == 0) || nextT == nextA) {
          ans++;
        }
      } else if (abs(T.c - A.c) == abs(T.r - A.r)) {
        auto sqStep = abs(T.c - A.c);
        if (sqStep > 0 && sqStep <= step) {
          auto sqT = apply(T, mT, sqStep);
          auto sqA = apply(A, mA, sqStep);
          if (sqT == sqA) ans++;
        } 
      }

      T = nextT;
      A = nextA;

      OT[indexT].step -= step;
      if (OT[indexT].step <= 0) indexT++;
      OA[indexA].step -= step;
      if (OA[indexA].step <= 0) indexA++;

      // deb([T, A], ans);
      moved += step;
      if (moved >= N) break;
    }

    return ans;
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
void runSolver() {
  static import std.datetime.stopwatch;
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(1)); BORDER.writeln; } }
  else problem();
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
