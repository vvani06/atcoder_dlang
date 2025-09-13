void main() { runSolver(); }

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto RND = Xorshift(unpredictableSeed);
  enum long INF = long.max / 3;

  auto N = scan!int;
  auto XY = scan!long(2 * N).chunks(2).array;

  auto solve() {
    while(!elapsed(500)) {
      int i = uniform(0, N);
      int j = uniform(0, N);
      if (i == j) continue;

      Line line = Line(XY[i], XY[j]);
      int covered;
      foreach(xy; XY) {
        if (line.covered(xy)) covered++;
      }

      if (covered > N / 2) {
        writeln("Yes");

        if (line.a.u == long.max) {
          line.a.u = -1;
          line.a.l = 0;
        }
        writefln("%s %s %s", -line.a.u, line.a.l, -line.b.u);
        return;
      }
    }

    writeln("No");
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

struct Rational {
  long u, l = 1;
  this(long u) { this.u = u; }
  this(long u, long l) {
    if (l == 0) assert("lower number cannot be 0");

    if (l < 0) {
      u *= -1;
      l *= -1;
    }
    const g = gcd(u.abs, l);
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

struct Line {
  Rational a, b;
  
  this(T)(T from, T to) {
    long dx = to[0] - from[0];
    long dy = to[1] - from[1];
    if (dy == 0) {
      a = long.max;
      b = from[1];
    } else if (dx == 0) {
      b = from[0];
    } else {
      a = Rational(dy, dx);
      b = Rational(from[1]) - Rational(from[0])*a;
    }
  }

  bool covered(T)(T coord) {
    if (a.u == long.max && b.u == coord[1]) return true; 
    if (a.u == 0 && b.u == coord[0]) return true; 

    auto yr = Rational(coord[0]) * a + b;
    return yr.u == coord[1];
  }
}
