module snippets.lazySegTree;

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

void problem() {
  auto W = scan!long();
  auto N = scan!long();
  auto LR = scan!int(2 * N).chunks(2);

  auto solve() {
    auto segtree = LazySegtree!"max(a, b)"(new long[](W + 1));

    long h;
    foreach(lr; LR) {
      const l = lr[0] - 1;
      const r = lr[1];
      const maxHeight = 1 + segtree.sum(l, r);
      maxHeight.writeln;

      segtree.update(l, r, maxHeight);
    }
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop;
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
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
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(true) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
