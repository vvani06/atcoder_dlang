void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto K = scan!int;
  auto A = scan!int(N);

  auto solve() {
    auto fermet = FermetCalculator!998_244_353(10000);
    
    auto counts = new int[](2001);
    foreach(a; A) counts[a]++;
    auto acc = counts.cumulativeFold!"a + b".array;
    auto zeros = counts[0];

    MInt9 ans;

    // Ak >= x となる場合の数 を求める
    // x = 0 の場合、すべての場合が該当して だんだん減っていく
    // それらの累積和が期待値となる
    foreach(x; 0..M + 1) {
      // x以下の値が確定的に存在する個数
      const smaller = acc[x] - acc[0];

      // ランダム値のうち、0 ~ K-smaller 個が x以下 の値を取るならば Ak >= x が成立する
      foreach(z; 0..zeros + 1) {
        if (smaller + z >= K) break;

        auto add = MInt9(fermet.combine(zeros, z));   // ランダム数の組み合わせパターン数
        add *= MInt9(x) ^^ z;                         // 「x以下の値を取る」方の組み合わせ数
        add *= MInt9(M - x) ^^ (zeros - z);           // 「xより大きい値を取る」方の組み合わせ数
        ans += add;
      }
    }

    MInt9 total = MInt9(M) ^^ zeros;
    return ans / total;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
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