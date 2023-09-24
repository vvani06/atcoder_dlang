void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto R = scan!int(N * M).chunks(M).array;
  
  auto RND = Xorshift(unpredictableSeed);
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

  auto solve() {
    auto A = M.iota.map!(m => N.iota.map!(n => R[n][m]).array).array;
    swap(N, M);

    const long idealScore = N * M;
    auto scores = A.map!(a => a.dup.sort.array.uniq.array.length).array;
    auto score = scores.sum;

    auto ys = N.iota.array;
    auto xs = M.iota.array;
    int badCount;
    while(!elapsed(1900)) {
      if (score == idealScore) {
        writeln("Yes");
        auto ans = M.iota.map!(m => N.iota.map!(n => A[n][m]).array).array;
        foreach(a; ans) "%(%s %)".writefln(a);
        return;
      }

      ys.randomShuffle(RND);
      auto x = xs.choice(RND);
      auto y1 = ys[0];
      auto y2 = ys[1];

      swap(A[y1][x], A[y2][x]);

      auto s1 = A[y1].dup.sort.array.uniq.array.length;
      auto s2 = A[y2].dup.sort.array.uniq.array.length;
      if (s1 + s2 + badCount/10 >= scores[y1] + scores[y2]) {
        score -= scores[y1] + scores[y2];
        scores[y1] = s1;
        scores[y2] = s2;
        score += scores[y1] + scores[y2];
        badCount = 0;
      } else {
        badCount++;
        swap(A[y1][x], A[y2][x]);
      }
    }

    // score.deb;
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
