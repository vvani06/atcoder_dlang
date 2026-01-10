void main() { runSolver(); }

void problem() {
  auto N = scan!long;
  auto NQ = scan!int;
  auto Q = scan!long(2 * NQ).chunks(2);

  auto solve() {
    struct Cover {
      long l, r;

      long cl() { return l * 2; }
      long cr() { return r * 2 + 1; }

      Cover[] split(Cover other) {
        Cover[] ret;

        if (cr <= other.cr && cl >= other.cl) {
          // 
        } else if (cr >= other.cr && cl <= other.cl) {
          ret ~= Cover(l, other.l - 1);
          ret ~= Cover(other.r + 1, r);
        } else if (other.cl <= cl && cl <= other.cr) {
          ret ~= Cover(other.r + 1, r);
        } else if (other.cl <= cr && cr <= other.cr) {
          ret ~= Cover(l, other.l - 1);
        } else {
          return [this];
        }

        return ret.filter!"a.sum > 0".array;
      }

      long sum() { return r - l + 1; }

      inout opCmp(inout Cover other) {
        return cmp(
          [r, l],
          [other.r, other.l]
        );
      }
    }

    auto rbt = [Cover(1, N)].redBlackTree;
    long total = N;
    foreach(l, r; Q.asTuples!2) {
      auto black = Cover(l, r);

      auto sub = new Cover[](0).redBlackTree;
      auto add = new Cover[](0).redBlackTree;
      foreach(white; rbt.lowerBound(Cover(l, r + 1)).retro) {
        if (white.r < black.l) break;

        sub.insert(white);
        add.insert(white.split(black));
      }
      foreach(white; rbt.upperBound(Cover(l, r - 1))) {
        if (black.r < white.l) break;

        sub.insert(white);
        add.insert(white.split(black));
      }

      foreach(s; sub) total -= s.sum;
      rbt.removeKey(sub.array);
      foreach(s; add) total += s.sum;
      rbt.insert(add.array);

      writeln(total);
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
