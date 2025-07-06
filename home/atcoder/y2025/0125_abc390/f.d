void main() { runSolver(); }

void problem() {
  auto N = scan!long;
  auto M = scan!int;
  auto A = scan!long;
  auto B = scan!long;
  auto LR = scan!long(2 * M).chunks(2).array ~ [N + 1, N + 1];
  enum long MAX_AB = 20;

  auto solve() {
    // 任意の手数でfrom => to に移動可能か
    bool canWalk(long from, long to) {
      long step = to - from;
      if (step == 0) return true;

      foreach(d; [A, B]) {
        long t = step / d;
        if (t*A <= step && step <= t*B) return true;
      }
      return false;
    }

    bool isBad(long x) {
      auto sorted = LR.assumeSorted;
      auto candidates = sorted.lowerBound([x, long.max]);
      if (candidates.empty) return false;

      auto l = candidates.back[0];
      auto r = candidates.back[1];
      return l <= x && x <= r;
    }

    auto pre = new long[](0).redBlackTree;
    auto cur = [1L].redBlackTree;
    foreach(i, l, r; lockstep((M + 1).iota, LR.map!"a[0]", LR.map!"a[1]")) {
      swap(pre, cur);
      cur.clear;
      cur.insert(pre.array.filter!(x => x >= l - MAX_AB));
      foreach(to; max(pre.front, l - MAX_AB)..l) {
        if (isBad(to)) continue;

        foreach(from; pre) {
          if (from > l) break;
          
          if (canWalk(from, to)) {
            cur.insert(to);
            break;
          }
        }
      }

      if (i == M) break;

      swap(pre, cur);
      cur.clear;
      foreach(to; r + 1..r + 1 + MAX_AB) {
        if (isBad(to)) continue;

        foreach(from; pre) {
          if (from == to || (from + A <= to && to <= from + B)) {
            cur.insert(to);
            break;
          }
        }
      }
    }

    return N in cur;
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
