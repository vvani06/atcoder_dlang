void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto S = scan!string.array;
  auto QN = scan!int;

  auto solve() {
    auto segtrees = new SegTree!("a + b", int)[](26);
    foreach(i; 0..26) segtrees[i] = SegTree!("a + b", int)(new int[](N), 0);
    foreach(i; 0..N) segtrees[S[i] - 'a'].update(i, 1);

    bool validate(int l, int r) {
      auto counts = segtrees.map!(st => st.sum(l, r)).array;

      // S[l, r] が昇順かどうか
      int offset = l;
      foreach(i, c; counts) {
        if (segtrees[i].sum(offset, offset + c) != c) return false;
        offset += c;
      }

      // 昇順の文字列の頭と尻を除く部分が完全一致するかどうか
      // aabbbcccdd が全体として、abbbcccd, aabbbcccd はOK, abbcccd などはNG とする
      int mi = 27;
      int ma = -1;
      foreach(int i, c; counts) {
        if (c > 0) {
          mi = min(mi, i);
          ma = max(ma, i);
        }
      }
      foreach(i; mi + 1..ma) {
        if (segtrees[i].sum(0, N) != counts[i]) return false;
      }

      return true;
    }

    foreach(_; 0..QN) {
      const qt = scan!int;
      if (qt == 1) {
        const x = scan!int - 1;
        const c = scan!dchar;

        const pre = S[x];
        S[x] = c;
        segtrees[pre - 'a'].update(x, 0);
        segtrees[c - 'a'].update(x, 1);
      } else {
        const l = scan!int - 1;
        const r = scan!int;
        writeln(YESNO[validate(l, r)]);
      }
    }
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std, core.bitop;
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

long countInvertions(T)(T[] arr) {
  auto segtree = SegTree!("a + b", long)(new long[](arr.length));
  long ret;
  long pre = -1;
  int[] adds;
  foreach(a; arr.enumerate(0).array.sort!"a[1] > b[1]") {
    auto i = a[0];
    auto n = a[1];
    if (pre != n) {
      foreach(ai; adds) segtree.update(ai, segtree.get(ai) + 1);   
      adds.length = 0;
    }
    adds ~= i;
    pre = n;
    ret += segtree.sum(0, i);
  }
  return ret;
}
