void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  struct Coord { int x, y, z; }
  struct Cube { Coord from, to; }
  auto C = scan!int(6 * N).chunks(6).map!(c => Cube(Coord(c[0], c[1], c[2]), Coord(c[3], c[4], c[5]))).array;

  auto solve() {
    auto seed = unpredictableSeed;
    enum BOUNDARY = 101;
    auto xy = new long[][][](BOUNDARY, BOUNDARY, BOUNDARY);
    auto yz = new long[][][](BOUNDARY, BOUNDARY, BOUNDARY);
    auto zx = new long[][][](BOUNDARY, BOUNDARY, BOUNDARY);

    foreach(i, c; C) {
      const hashed = i.hashOf(seed);
      foreach(x; c.from.x..c.to.x) foreach(y; c.from.y..c.to.y) {
        xy[x][y][c.from.z] ^= hashed;
        xy[x][y][c.to.z] ^= hashed;
      }
      foreach(y; c.from.y..c.to.y) foreach(z; c.from.z..c.to.z) {
        yz[c.from.x][y][z] ^= hashed;
        yz[c.to.x][y][z] ^= hashed;
      }
      foreach(z; c.from.z..c.to.z) foreach(x; c.from.x..c.to.x) {
        zx[x][c.from.y][z] ^= hashed;
        zx[x][c.to.y][z] ^= hashed;
      }
    }

    foreach(i, c; C) {
      const hashed = i.hashOf(seed);
      bool[long] count;
      foreach(x; c.from.x..c.to.x) foreach(y; c.from.y..c.to.y) {
        count[xy[x][y][c.from.z]] = true;
        count[xy[x][y][c.to.z]] = true;
      }
      foreach(y; c.from.y..c.to.y) foreach(z; c.from.z..c.to.z) {
        count[yz[c.from.x][y][z]] = true;
        count[yz[c.to.x][y][z]] = true;
      }
      foreach(z; c.from.z..c.to.z) foreach(x; c.from.x..c.to.x) {
        count[zx[x][c.from.y][z]] = true;
        count[zx[x][c.to.y][z]] = true;
      }

      count.remove(hashed);
      writeln(count.length);
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
void deb(T ...)(T t){ debug asAnswer(t).writeln; }
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
