void main() { runSolver(); }

void problem() {
  auto A = scan!real;
  auto B = scan!real;
  enum real T120 = PI * 2 / 3;
  enum real T30 = PI / 6;
  alias Vector = Vector2!real;

  auto solve() {
    if (A < B) swap(A, B);
    A = min(A, B * 2.0L / 3.0L.sqrt);

    bool isOk(real t) {
      auto p1 = Vector(A, sin(t) * A);
      auto p2 = p1 + p1.rotate(PI * 2 / 3);
      return p2.y <= B;
    }

    auto theta = binarySearch(&isOk, 0.0L, T30 + 1e-10);
    return Vector(A, sin(theta)*A).norm.sqrt;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std, core.bitop;
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

struct Vector2(T) {
  T x, y;
  Vector2 add(Vector2 other) { return Vector2(x + other.x, y + other.y ); }
  Vector2 opAdd(Vector2 other) { return add(other); }
  Vector2 sub(Vector2 other) { return Vector2(x - other.x, y - other.y ); }
  Vector2 opSub(Vector2 other) { return sub(other); }
  T norm() { return x*x + y*y; }
  T norm(Vector2 other) { return (x - other.x)*(x - other.x) + (y - other.y)*(y - other.y); }
  T dot(Vector2 other) { return x*other.y - y*other.x; }
  Vector2 rotate(real theta) { return Vector2(x * cos(theta) - y * sin(theta), x * sin(theta) + y * cos(theta)); }
  Vector2 normalize() {if (x == 0 || y == 0) return Vector2(x == 0 ? 0 : x/x.abs, y == 0 ? 0 : y/y.abs);const gcd = x.abs.gcd(y.abs);return Vector2(x / gcd, y / gcd);}
}

K binarySearch(K)(bool delegate(K) cond, K l, K r) { return binarySearch((K k) => k, cond, l, r); }
T binarySearch(T, K)(K delegate(T) fn, bool delegate(K) cond, T l, T r) {
  auto ok = l;
  auto ng = r;
  const T TWO = 2;
 
  bool again() {
    static if (is(T == float) || is(T == double) || is(T == real)) {
      return !ng.approxEqual(ok, 1e-10, 1e-10);
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
