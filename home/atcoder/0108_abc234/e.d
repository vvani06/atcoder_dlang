void main() { runSolver(); }

void problem() {
  auto N = scan!long;

  auto solve() {
    bool isOk(long x) {
      if (x < 10) return true;

      long t = x % 10;
      x /= 10;
      t -= x % 10;
      while(x > 0) {
        long tt = x % 10;
        x /= 10;
        if (x == 0) break;
        tt -= x % 10;
        if (t != tt) return false;
      }

      return true;
    }

    long createAns(long head2, long keta) {
      string ret = head2.to!string;
      const spr = ret[1] - ret[0];

      foreach(i; 0..keta - 2) {
        ret ~= ret[$ - 1] + spr;
      }
      // ret.deb;
      return ret.to!long;
    }

    if (isOk(N)) return N;

    auto SN = N.to!string;
    long keta = SN.length;
    long rest = keta - 1;
    long head = SN[0] - '0';

    foreach(i; (SN[1] - '0')..10) {
      const long spr = i - head;
      [head, i, spr, head + rest*spr].deb;

      if (head + rest*spr >= 10) continue;
      if (head + rest*spr < 0) continue;

      const ans = createAns(head*10 + i, keta);
      if (ans > N) return createAns(head*10 + i, keta);
    }

    head++;
    foreach(i; 0..10) {
      const long spr = i - head;
      // [head, i, spr].deb;
      if (head + rest*spr >= 0) return createAns(head*10 + i, keta);
    }

    return 0;
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
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

struct UnionFind {
  long[] parent;
  long[] sizes;

  this(long size) {
    parent.length = size;
    foreach(i; 0..size) parent[i] = i;

    sizes.length = size;
    sizes[] = 1;
  }

  long root(long x) {
    if (parent[x] == x) return x;
    return parent[x] = root(parent[x]);
  }

  long unite(long x, long y) {
    long rootX = root(x);
    long rootY = root(y);
    if (rootX == rootY) return rootY;

    if (sizes[rootX] < sizes[rootY]) {
      sizes[rootY] += sizes[rootX];
      return parent[rootY] = rootX;
    } else {
      sizes[rootX] += sizes[rootY];
      return parent[rootX] = rootY;
    }
  }

  bool same(long x, long y) {
    long rootX = root(x);
    long rootY = root(y);

    return rootX == rootY;
  }
}
