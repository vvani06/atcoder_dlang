void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto S = scan!string(N);

  auto solve() {
    auto opeRot = Matrix2.moveY(N - 1).mul(Matrix2.rotateRight);
    auto rotations = new Matrix2[](N);

    rotations[0] = opeRot;
    foreach(i; 0..N - 1) {
      rotations[i + 1] = opeRot.mul(rotations[i]);
    }

    char[][] ans = new char[][](N, N);
    foreach(r; 0..N) foreach(c; 0..N) {
      auto d = min(r, c, N - r - 1, N - c - 1);
      auto base = Point(c, r);
      auto p = rotations[d].mul(base);

      // [base, p].deb;
      ans[r][c] = S[p.y][p.x];
    }

    foreach(s; ans.map!"a.to!string") s.writeln;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
import core.bitop;
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

long[][] basePacks(long base, long size) {
  auto ret = new long[][](base^^size, size);
  foreach(i; 0..base^^size) {
    long x = i;
    foreach(b; 0..size) {
      ret[i][b] = x % base;
      x /= base;
    }
  }
  return ret;
}

alias Point = Tuple!(long, "x", long, "y");

struct Matrix2 {
  long[][] v;

  this(long[][] value) {
    v = value;
  }

  long x() {
    return v[0][2];
  }

  long y() {
    return v[1][2];
  }

  Point mul(Point p) {
    auto m = [p.x, p.y, 1];
    auto mm = [0L, 0, 0];
    foreach(i; 0..3) {
      foreach(j; 0..3) mm[i] += v[i][j] * m[j];
    }

    return Point(mm[0], mm[1]);
  }

  Matrix2 mul(Matrix2 other) {
    auto vd = [[0L, 0, 0], [0L, 0, 0], [0L, 0, 0]];
    foreach(i; 0..3) {
      foreach(j; 0..3) {
        // deb("----- ", i, ", ", j);
        foreach(k; 0..3) {
          vd[i][j] += v[i][k] * other.v[k][j];
        }
      }
    }
    // deb("a: ", v);
    // deb("b: ", other.v);
    // deb("ab: ", vd);
    return Matrix2(vd);
  }

  static Matrix2 from(long x, long y) {
    return Matrix2([
      [1 , 0, x],
      [0L, 1, y],
      [0L, 0, 1]
    ]);
  }

  static Matrix2 moveX(long x) {
    return Matrix2([
      [1L, 0, x],
      [0L, 1, 0],
      [0L, 0, 1]
    ]);
  }

  static Matrix2 mirrorX() {
    return Matrix2([
      [-1L,  0, 0],
      [ 0L,  1, 0],
      [ 0L,  0, 1]
    ]);
  }

  static Matrix2 moveY(long y) {
    return Matrix2([
      [1L, 0, 0],
      [0L, 1, y],
      [0L, 0, 1]
    ]);
  }

  static Matrix2 mirrorY() {
    return Matrix2([
      [1L,   0, 0],
      [0L , -1, 0],
      [0L ,  0, 1]
    ]);
  }

  static Matrix2 rotateLeft() {
    return Matrix2([
      [0L, -1, 0],
      [1L,  0, 0],
      [0L,  0, 1]
    ]);
  }

  static Matrix2 rotateRight() {
    return Matrix2([
      [ 0L, 1, 0],
      [-1L, 0, 0],
      [ 0L, 0, 1]
    ]);
  }
}
