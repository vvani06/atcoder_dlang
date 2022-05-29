void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto Q = scan!int;

  class Query {
    int id;
    int t;
    long l, r, x, i, j;
    Query[] forwards;

    this(int id, int t) {
      l = r = x = i = j = -1;
      this.id = id;
      this.t = t;
      if (t == 1) {
        l = scan!long - 1;
        r = scan!long - 1;
        x = scan!long;
      }
      if (t == 2) {
        i = scan!long - 1;
        x = scan!long;
      }
      if (t == 3) {
        i = scan!long - 1;
        j = scan!long - 1;
      }
    }
  }

  auto solve() {
    Query[] queries;
    foreach(q; 0..Q) queries ~= new Query(q, scan!int);

    Query[long] lastQ2ByRow;
    auto ans = new long[](Q);
    ans[] = -1;

    foreach(qt, query; queries) {
      if (query.t == 2) {
        lastQ2ByRow[query.i] = query;
      }
      else if (query.t == 3) {
        ans[qt] = 0;
        if (query.i in lastQ2ByRow) {
          auto lastQ2 = lastQ2ByRow[query.i];
          lastQ2.forwards ~= query;
          ans[qt] = lastQ2.x;
        }
      }
    }

    auto segtree = SegTree!("a + b", long)(new long[](M + 1));
    foreach(qt, query; queries) {
      if (query.t == 1) {
        segtree.update(query.l, segtree.get(query.l) + query.x);
        segtree.update(query.r + 1, segtree.get(query.r + 1) - query.x);
      }
      else if (query.t == 2) {
        foreach(q; query.forwards) {
          ans[q.id] -= segtree.sum(0, q.j + 1);
        }
      }
      else if (query.t == 3) {
        ans[qt] += segtree.sum(0, query.j + 1);
      }
    }

    ans.filter!"a >= 0".each!writeln;
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

struct SegTree(alias pred = "a + b", T = long) {
  alias predFun = binaryFun!pred;
  size_t size;
  T[] data;
  T monoid;
 
  this(T[] src, T monoid = T.init) {
    this.monoid = monoid;

    for(long i = 2; i < 2L^^32; i *= 2) {
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
    if (r < 0) r = size;
    
    if (r <= a || b <= l) return monoid;
    if (a <= l && r <= b) return data[k];
 
    T leftValue = sum(a, b, 2*k, l, (l + r) / 2);
    T rightValue = sum(a, b, 2*k + 1, (l + r) / 2, r);
    return predFun(leftValue, rightValue);
  }
}
