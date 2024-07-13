void main() { runSolver(); }

void problem() {
  auto K = scan!int;
  auto C = scan!int(26);

  auto solve() {
    auto fermet = FermetCalculator!998_244_353(1001);

    auto dp = new MInt9[][](27, K + 1);
    dp[0][0] = MInt9(1);

    foreach(a, c; C.enumerate(0)) {
      foreach(from; 0..K + 1) {
        foreach(add; 0..c + 1) {
          auto to = from + add;
          if (to > K) continue;

          dp[a + 1][to] += dp[a][from] * MInt9(fermet.combine(to, add));
        }
      }
    }

    return dp[26][1..$].sum;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std, core.bitop;
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

struct FermetCalculator(uint MD) {
  long[] factrial; // 階乗
  long[] inverse;  // 逆元
  
  this(long size) {
    factrial = new long[size + 1];
    inverse = new long[size + 1];
    factrial[0] = 1;
    inverse[0] = 1;
    
    for (long i = 1; i <= size; i++) {
      factrial[i] = (factrial[i - 1] * i) % MD;  // 階乗を求める
      inverse[i] = pow(factrial[i], MD - 2) % MD; // フェルマーの小定理で逆元を求める
    }
  }
  
  long combine(long n, long k) {
    if (n < k) return 1;
    return factrial[n] * inverse[k] % MD * inverse[n - k] % MD;
  }
  
  long pow(long x, long n) { //x^n 計算量O(logn)
    long ans = 1;
    while (n > 0) {
      if ((n & 1) == 1) {
        ans = ans * x % MD;
      }
      x = x * x % MD; //一周する度にx, x^2, x^4, x^8となる
      n >>= 1; //桁をずらす n = n >> 1
    }
    return ans;
  }
}
