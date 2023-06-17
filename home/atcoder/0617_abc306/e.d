void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto K = scan!int;
  auto Q = scan!int;
  auto XY = scan!int(2 * Q).chunks(2).array;

  auto solve() {

    struct Value {
      long num, count, sum;

      this(long n, long c) {
        num = n;
        count = c;
        sum = num * count;
      }

      this(long n, long c, long s) {
        num = n;
        count = c;
        sum = s;
      }

      Value add(Value other) {
        return Value(0L, count + other.count, sum + other.sum);
      }
    }

    auto values = new Value[](0);
    values ~= Value(0, N);
    auto compressed = (0L ~ XY.map!"a[1]".array).sort.uniq.array;
    foreach(c; compressed[1..$]) {
      values ~= Value(c, 0);
    }

    int[long] ci;
    foreach(i, c; compressed) ci[c] = i.to!int;

    values.deb;
    ci.deb;

    auto segtree = SegTree!("a.add(b)", Value)(values, Value(0, 0, 0));
    auto xs = (0L).repeat(N + 1).array;
    
    int r = compressed.length.to!int + 1;
    foreach(xy; XY) {
      // xy.deb;
      auto x = xy[0];
      auto y = xy[1];

      auto before = xs[x];
      auto after = xs[x] = y;

      // segtree.data.deb;
      segtree.update(ci[before], Value(before, segtree.get(ci[before]).count - 1));
      segtree.update(ci[y], Value(y, segtree.get(ci[y]).count + 1));
      // segtree.data.deb;

      bool isOk(int l) {
        return segtree.sum(l, r).count >= K;
      }

      auto l = binarySearch(&isOk, 0, r);
      auto s = segtree.sum(l, r);
      auto ans = s.sum;
      if (s.count > K) {
        ans -= compressed[l] * (s.count - K);
      }

      ans.writeln;
    }

  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
import core.bitop;
T[] compress(T)(T[] arr, T origin = T.init) { T[T] indecies; arr.dup.sort.uniq.enumerate(origin).each!((i, t) => indecies[t] = i); return arr.map!(t => indecies[t]).array; }
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
struct ModInt(uint MD) if (MD < int.max) {ulong v;this(string v) {this(v.to!long);}this(int v) {this(long(v));}this(long v) {this.v = (v%MD+MD)%MD;}void opAssign(long t) {v = (t%MD+MD)%MD;}static auto normS(ulong x) {return (x<MD)?x:x-MD;}static auto make(ulong x) {ModInt m; m.v = x; return m;}auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r.v));}auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r.v));}auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r.v%MD).to!ulong);}auto opBinary(string op:"^^", T)(T r) const {long x=v;long y=1;while(r){if(r%2==1)y=(y*x)%MD;x=x^^2%MD;r/=2;} return make(y);}auto opBinary(string op:"/")(ModInt r) const {return this*memoize!inv(r);}static ModInt inv(ModInt x) {return x^^(MD-2);}string toString() const {return v.to!string;}auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}}
alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);
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
  static import std.datetime.stopwatch;
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct SegTree(alias pred = "a + b", T = long) {
  alias predFun = binaryFun!pred;
  int size;
  T[] data;
  T monoid;
 
  this(T[] src, T monoid = T.init) {
    this.monoid = monoid;

    for(int i = 2; i < 2L^^32; i *= 2) {
      if (src.length <= i) {
        size = i;
        break;
      }
    }
    
    data = new T[](size * 2);
    foreach(i, s; src) data[i + size] = s;
    foreach_reverse(b; 1..size) {
      data[b] = predFun(data[b * 2], data[b * 2 + 1]);
    }
  }
 
  void update(int index, T value) {
    int i = index + size;
    data[i] = value;
    while(i > 0) {
      i /= 2;
      data[i] = predFun(data[i * 2], data[i * 2 + 1]);
    }
  }
 
  T get(int index) {
    return data[index + size];
  }
 
  T sum(int a, int b, int k = 1, int l = 0, int r = -1) {
    if (r < 0) r = size;
    
    if (r <= a || b <= l) return monoid;
    if (a <= l && r <= b) return data[k];
 
    T leftValue = sum(a, b, 2*k, l, (l + r) / 2);
    T rightValue = sum(a, b, 2*k + 1, (l + r) / 2, r);
    return predFun(leftValue, rightValue);
  }
}

long countInvertions(T)(T[] arr) {
  auto segtree = SegTree!("a + b", long)(new long[](arr.length));
  long ret;
  long pre = -1;
  int[] adds;
  foreach(a; arr.enumerate(0).array.sort!"a[1] > b[1]") {
    auto i = a[0];
    auto n = a[1];
    if (pre != n) {
      foreach(ai; adds) segtree.update(ai, segtree.get(ai) + 1);   
      adds.length = 0;
    }
    adds ~= i;
    pre = n;
    ret += segtree.sum(0, i);
  }
  return ret;
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