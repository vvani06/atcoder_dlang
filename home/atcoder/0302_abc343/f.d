void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto QN = scan!int;
  auto A = scan!int(N);
  auto Q = scan!int(3 * QN).chunks(3);

  auto solve() {
    // auto nums = A ~ Q.filter!"a[0] == 1".map!"a[2]".array;
    // auto comp = nums.compress;
    // nums.deb;
    // comp.deb;
    // int[int] conv;
    // foreach(i, n; nums) conv[n] = comp[i];
    // conv.deb;

    struct NC {
      int first = 0, firstCount = 0;
      int second = 0, secondCount = 0;

      NC add(NC other) {
        NC ret;

        ret.first = max(first, other.first);
        if (ret.first == first) ret.firstCount += firstCount;
        if (ret.first == other.first) ret.firstCount += other.firstCount;

        if (first < ret.first) ret.second = first;
        if (other.first < ret.first) ret.second.chmax(other.first);
        ret.second.chmax(max(second, other.second));

        if (ret.second == first) ret.secondCount += firstCount;
        if (ret.second == other.first) ret.secondCount += other.firstCount;
        if (ret.second == second) ret.secondCount += secondCount;
        if (ret.second == other.second) ret.secondCount += other.secondCount;

        // if (first == other.first) {
        //   ret.firstCunt = firstCount + other.firstCount;
          
        // }
        // if (ret.first == first) {
        //   ret.firstCount = firstCount;
        //   if (other.first == first) ret.firstCount += other.firstCount;
        // } else {
          
        // }

        return ret;
      }
    }

    auto segtree = SegTree!("a.add(b)", NC)(A.map!(a => NC(a, 1, 0, 0)).array, NC(-1, 0, 0, 0));

    foreach(q; Q) {
      if (q[0] == 1) {
        auto p = q[1] - 1;
        auto x = q[2];
        segtree.update(p, NC(x, 1, 0, 0));
      } else {
        auto l = q[1] - 1;
        auto r = q[2];

        segtree.sum(l, r).secondCount.writeln;
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

struct SegTree(alias pred = "a + b", T = long) {
  alias predFun = binaryFun!pred;
  int size;
  T[] data;
  T monoid;
 
  this(T[] src, T monoid = T.init) {
    this.monoid = monoid;

    for(int i = 2; i < 2L^^32; i *= 2) {
      if (src.length <= i) {
        size = i;
        break;
      }
    }
    
    data = new T[](size * 2);
    foreach(i, s; src) data[i + size] = s;
    foreach_reverse(b; 1..size) {
      data[b] = predFun(data[b * 2], data[b * 2 + 1]);
    }
  }
 
  void update(int index, T value) {
    int i = index + size;
    data[i] = value;
    while(i > 0) {
      i /= 2;
      data[i] = predFun(data[i * 2], data[i * 2 + 1]);
    }
  }
 
  T get(int index) {
    return data[index + size];
  }
 
  T sum(int a, int b, int k = 1, int l = 0, int r = -1) {
    if (r < 0) r = size;
    
    if (r <= a || b <= l) return monoid;
    if (a <= l && r <= b) return data[k];
 
    T leftValue = sum(a, b, 2*k, l, (l + r) / 2);
    T rightValue = sum(a, b, 2*k + 1, (l + r) / 2, r);
    return predFun(leftValue, rightValue);
  }
}
