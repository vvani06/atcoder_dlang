void main() { runSolver(); }

void problem() {
  auto T = scan!int();
  alias Vector = Vector2!real;

  auto subSolve(real[] r) {
    auto ts = Vector(r[0], r[1]);
    auto tg = Vector(r[2], r[3]);
    auto as = Vector(r[4], r[5]);
    auto ag = Vector(r[6], r[7]);

    // r.deb;
    // [ts, tg].deb;
    // [as, ag].deb;

    auto tn = ts.norm(tg).sqrt;
    auto an = as.norm(ag).sqrt;

    real calcDistance(real time) {
      auto tRatio = min(1.0, time / tn);
      auto aRatio = min(1.0, time / an);

      auto t = tg * tRatio + ts * (1.0 - tRatio);
      auto a = ag * aRatio + as * (1.0 - aRatio);
      return t.norm(a);
    }

    real ans = long.max;
    ans = min(ans, ternarySearch(&calcDistance, 0.0, max(tn, an), TernarySearchTarget.Min)[1]);
    ans = min(ans, ternarySearch(&calcDistance, 0.0, min(tn, an), TernarySearchTarget.Min)[1]);
    ans = min(ans, ternarySearch(&calcDistance, min(an, tn), max(tn, an), TernarySearchTarget.Min)[1]);

    return "%.16f".format(ans.sqrt);
  }

  auto solve() {
    foreach(_; 0..T) {
      writeln(subSolve(scan!real(8)));
    }
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

struct Vector2(T) {
  T x, y;
  Vector2 add(Vector2 other) { return Vector2(x + other.x, y + other.y ); }
  Vector2 opBinary(string op: "+")(Vector2 other) { return add(other); }
  Vector2 sub(Vector2 other) { return Vector2(x - other.x, y - other.y ); }
  Vector2 opBinary(string op: "-")(Vector2 other) { return sub(other); }
  Vector2 mul(T t) { return Vector2(x * t, y * t ); }
  Vector2 opBinary(string op: "*")(T t) { return mul(t); }

  T norm() { return x*x + y*y; }
  T norm(Vector2 other) { return (x - other.x)*(x - other.x) + (y - other.y)*(y - other.y); }
  T dot(Vector2 other) { return x*other.y - y*other.x; }
  Vector2 rotate(real theta) { return Vector2(x * cos(theta) - y * sin(theta), x * sin(theta) + y * cos(theta)); }
  Vector2 normalize() {if (x == 0 || y == 0) return Vector2(x == 0 ? 0 : x/x.abs, y == 0 ? 0 : y/y.abs);const gcd = x.abs.gcd(y.abs);return Vector2(x / gcd, y / gcd);}
}

enum TernarySearchTarget { Min, Max }
Tuple!(T, K) ternarySearch(T, K)(K delegate(T) fn, T l, T r, TernarySearchTarget target = TernarySearchTarget.Min) {
  auto low = l;
  auto high = r;
  const T THREE = 3;
 
  bool again() {
    static if (is(T == float) || is(T == double) || is(T == real)) {
      return !high.isClose(low, 1e-10, 1e-10);
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
