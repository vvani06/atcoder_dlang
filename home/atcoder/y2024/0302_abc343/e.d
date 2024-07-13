void main() { runSolver(); }

void problem() {
  auto V = scan!long(3);

  static struct Cube {
    long sx, sy, sz;
    long ex, ey, ez;

    long segment() {
      return (ex - sx) * (ey - sy) * (ez - sz);
    }

    static Cube overlaped(Cube[] cubes) {
      auto sx = cubes.map!"a.sx".maxElement;
      auto sy = cubes.map!"a.sy".maxElement;
      auto sz = cubes.map!"a.sz".maxElement;
      return Cube(
        sx,
        sy,
        sz,
        max(sx, cubes.map!"a.ex".minElement),
        max(sy, cubes.map!"a.ey".minElement),
        max(sz, cubes.map!"a.ez".minElement),
      );
    }
  }

  auto solve() {
    Cube cube777(long x, long y, long z) {
      return Cube(x, y, z, x+7, y+7, z+7);
    }

    long[] calcSegments(Cube c1, Cube c2, Cube c3) {
      long seg3 = Cube.overlaped([c1, c2, c3]).segment;
      long seg2 = [[c1, c2], [c1, c3], [c2, c3]].map!(c => Cube.overlaped(c).segment).sum - seg3*3;
      long seg1 = [c1, c2, c3].map!"a.segment".sum - seg2*2 - seg3*3;
      return [seg1, seg2, seg3];
    }

    Cube c1 = cube777(0, 0, 0);
    foreach(x1; -1..8) foreach(y1; -1..8) foreach(z1; -1..8) {
      Cube c2 = cube777(x1, y1, z1);
      foreach(x2; -1..8) foreach(y2; -1..8) foreach(z2; -1..8) {
        Cube c3 = cube777(x2, y2, z2);

        long seg3 = Cube.overlaped([c1, c2, c3]).segment;
        long seg2 = [[c1, c2], [c1, c3], [c2, c3]].map!(c => Cube.overlaped(c).segment).sum - seg3*3;
        long seg1 = [c1, c2, c3].map!"a.segment".sum - seg2*2 - seg3*3;

        auto segs = [seg1, seg2, seg3];
        if (V == segs) {
          writeln("Yes");
          writefln("%(%s %)", [c1.sx, c1.sy, c1.sz, c2.sx, c2.sy, c2.sz, c3.sx, c3.sy, c3.sz]);
          return;
        }
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
  else if (is(T == string)) fn().writeln;
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
