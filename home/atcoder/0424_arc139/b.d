void main() { runSolver(); }

void problem() {
  auto T = scan!long;

  auto subSolve() {
    auto N = scan!long;
    auto A = scan!long;
    auto B = scan!long;
    auto X = scan!long;
    auto Y = scan!long;
    auto Z = scan!long;

    auto r1 = Rational(1, X);
    auto ra = Rational(A, Y);
    auto rb = Rational(B, Z);
    if (ra < rb) swap(ra, rb);

    long ans = N * X;
    if (N/ra.u < ra.u - 1) {
      foreach(a; 0..1 + N/ra.u) {
        auto restB = N - a*ra.u;
        auto b = restB/rb.u;
        auto rest1 = restB - b*rb.u;
        if (ans.chmin(a*ra.l + b*rb.l + rest1*r1.l)) {
          // [ans, a, b, rest1].deb;
        }
      }
    } else {
      foreach(b; 0..min(ra.u, 1 + N/rb.u)) {
        auto restA = N - b*rb.u;
        auto a = restA/ra.u;
        auto rest1 = restA - a*ra.u;
        if (ans.chmin(a*ra.l + b*rb.l + rest1*r1.l)) {
          // [ans, a, b, rest1].deb;
        }
      }
    }
    
    return ans;
  }

  auto solve() {
    foreach(i; 0..T) subSolve.writeln;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop;
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
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
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct Rational {
  long u, l = 1;
  this(long u) { this.u = u; }
  this(long u, long l, bool asis = false) {
    if (l == 0) assert("lower number cannot be 0");

    if (l < 0) {
      u *= -1;
      l *= -1;
    }
    const g = asis ? 1 : gcd(u, l);
    this.u = u / g;
    this.l = l / g;
  }

  Rational add(Rational o) {
    const nl = l * o.l;
    const nu = u * o.l + o.u * l;
    return Rational(nu, nl);
  }
  Rational sub(Rational o) { return add(Rational(-o.u, o.l)); }
  Rational mul(Rational o) { return Rational(u * o.u, l * o.l); }
  Rational div(Rational o) { return Rational(u * o.l, l * o.u); }

  Rational opBinary(string op: "+")(Rational o) { return add(o); }
  Rational opBinary(string op: "-")(Rational o) { return sub(o); }
  Rational opBinary(string op: "*")(Rational o) { return mul(o); }
  Rational opBinary(string op: "/")(Rational o) { return div(o); }
  void opAssign(T)(t v) { u = v; }

  int opCmp(Rational o) {
    const me = u * o.l;
    const other = o.u * l;
    return me > other ? 1 : me < other ? -1 : 0;
  }
}