void main() { runSolver(); }

void problem() {
  auto T = scan!int;

  alias Speed = Tuple!(long, "from", long, "to", long, "sec", long, "acc");

  auto subSolve(long N, long M, long[][] XY) {
    [[[N, M]], XY].deb;
    Speed[] B = [Speed(0, 0, 0, 0)];
    foreach(i, xy; XY) {
      auto s = B[$ - 1];
      B ~= Speed(s.to + xy[0], s.to + xy[0]*xy[1], xy[1], xy[0] + (i == 0 ? 1 : 0));
    }
    // B.each!deb;
    
    long ans = B[1].from;
    long pos;
    foreach(s; B[1..$]) {
      if (s.from > 0 && s.to < 0) {
        // s.deb;
        auto cycle = 1 + (s.from / s.acc.abs);
        auto add = (cycle * (s.from*2 + (cycle - 1)*s.acc)) / 2;
        ans = max(ans, pos + add);
        [ans, cycle].deb;
      }

      pos += s.sec * (s.from + s.to) / 2;
      ans = max(ans, pos);
      pos.deb;
    }

    return ans;
  }

  // 380000

  auto solve() {
    foreach(_; 0..T) {
      auto N = scan!long;
      auto M = scan!long;
      auto XY = scan!long(2 * N).chunks(2).array;
      subSolve(N, M, XY).writeln;
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

// -----------------------------------------------


struct UnionFind {
  long[] parent;

  this(long size) {
    parent.length = size;
    foreach(i; 0..size) parent[i] = i;
  }

  long root(long x) {
    if (parent[x] == x) return x;
    return parent[x] = root(parent[x]);
  }

  long unite(long x, long y) {
    long rootX = root(x);
    long rootY = root(y);

    if (rootX == rootY) return rootY;
    return parent[rootX] = rootY;
  }

  bool same(long x, long y) {
    long rootX = root(x);
    long rootY = root(y);

    return rootX == rootY;
  }
}
