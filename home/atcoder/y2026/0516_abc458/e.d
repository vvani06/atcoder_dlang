void main() { runSolver(); }

void problem() {
  auto X = scan!long(3);

  auto solve() {
    auto fermet = FermetCalculator!998_244_353(10^^6 * 9);

    MInt9 ans;
    auto cand = X[1] + 1;
    foreach(one; 1..cand) {
      if (one > X[0]) break;

      auto t1 = MInt9(fermet.combine(cand, one));

      auto freeOne = X[0] - one;
      auto t2 = MInt9(fermet.combine(one + freeOne - 1, freeOne));

      auto three = cand - one;
      auto t3 = MInt9(fermet.combine(three + X[2] - 1, X[2]));

      // [[one, freeOne, three]].deb;
      // [t1, t2, t3, t1*t2*t3].deb;

      auto t = t1 * t2 * t3;
      ans += t;
    }
    
    return ans;
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
void runSolver(bool multiCase = false) {
  static import std.datetime.stopwatch;
  debug { if (multiCase) writeln("! Run as multi-case"); }
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(multiCase ? scan!int : 1)); BORDER.writeln; } }
  else foreach(_; 0..multiCase ? scan!int : 1) problem();
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

  long permutation(long n, long k) {
    if (n < k) return 1;

    return factrial[n] % MD * inverse[n - k] % MD;
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
