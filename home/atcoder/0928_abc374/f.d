void main() { runSolver(); }

void problem() {
  enum INF = long.max / 3;
  auto N = scan!int;
  auto K = scan!int;
  auto X = scan!int;
  auto T = -INF ~ scan!long(N);

  auto solve() {

    auto dp = new long[][](N + 1, N + 1);
    foreach(ref d; dp) d[] = INF;
    dp[0][0] = 0;

    foreach(t, i; zip(T[1..$].enumerate(1))) {
      foreach(from; max(0, i - K)..i) {
        if (dp[from][from] == INF) continue;
        
        // 出荷する
        dp[i][i].chmin(dp[from][from] + );

        // 出荷しない
      }
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
size_t digitSize(T)(T t) { return t.to!string.length; }
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

struct LazySegtree(alias pred = "a + b", T = long) {
  alias predFun = binaryFun!pred;
  size_t size;
  T[] data, waited;
  T monoid, undef;
 
  this(T[] src, T monoid = T.init, T undef = T.min) {
    for(long i = 2; i < 2L^^32; i *= 2) {
      if (src.length <= i) {
        size = i;
        break;
      }
    }
    
    data = new T[](size * 2);
    waited = new T[](size * 2);
    waited[] = undef;
    foreach(i, s; src) data[i + size] = s;
    foreach_reverse(b; 1..size) {
      data[b] = predFun(data[b * 2], data[b * 2 + 1]);
    }
  }

  void eval(size_t k) {
    if (waited[k] == undef) return;

    if (k < size) {
      waited[k * 2] = waited[k];
      waited[k * 2 + 1] = waited[k];
    }
    data[k] = waited[k];
    waited[k] = undef;
  }
 
  void update(long a, long b, T x, size_t k = 1, long l = 0, long r = -1) {
    eval(k);
    if (r < 0) r = size;
    
    if (a <= l && r <= b) {
      waited[k] = x;
      eval(k);
    } else if (a < r && l < b) {
      update(a, b, x, 2*k, l, (l + r) / 2);
      update(a, b, x, 2*k + 1, (l + r) / 2, r);
      data[k] = predFun(data[2*k], data[2*k + 1]);
    }
  }
 
  void update(long index, T value) {
    long i = index + size;
    data[i] = value;
    while(i > 0) {
      i /= 2;
      data[i] = predFun(data[i * 2], data[i * 2 + 1]);
    }
  }
 
  T get(long index) {
    return data[index + size];
  }
 
  T sum(long a, long b, size_t k = 1, long l = 0, long r = -1) {
    eval(k);
    if (r < 0) r = size;
    
    if (r <= a || b <= l) return monoid;
    if (a <= l && r <= b) return data[k];
 
    T leftValue = sum(a, b, 2*k, l, (l + r) / 2);
    T rightValue = sum(a, b, 2*k + 1, (l + r) / 2, r);
    return predFun(leftValue, rightValue);
  }
}

// void problem() {
//   auto W = scan!long();
//   auto N = scan!long();
//   auto LR = scan!int(2 * N).chunks(2);

//   auto solve() {
//     auto segtree = LazySegtree!"max(a, b)"(new long[](W + 1));

//     long h;
//     foreach(lr; LR) {
//       const l = lr[0] - 1;
//       const r = lr[1];
//       const maxHeight = 1 + segtree.sum(l, r);
//       maxHeight.writeln;

//       segtree.update(l, r, maxHeight);
//     }
//   }

//   outputForAtCoder(&solve);
// }