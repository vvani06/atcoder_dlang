void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto D = scan!int(N);
  auto E = scan!int(2 * M).map!"a - 1".chunks(2);

  auto solve() {
    if (D.sum != N*2 - 2) return [-1];

    auto uf = UnionFind(N);
    bool[int][] conn;
    conn.length = N;
    foreach(e; E) {
      conn[e[0]][e[1]] = true;
      conn[e[1]][e[0]] = true;
      uf.unite(e[0], e[1]);
      if (--D[e[0]] < 0) return [-1];
      if (--D[e[1]] < 0) return [-1];
    }

    auto lacks = new int[](N);
    int[int][] perRoot;
    perRoot.length = N;
    foreach(i; 0..N) {
      lacks[uf.root(i)] += D[i];
      if (D[i] > 0) perRoot[uf.root(i)][i] = D[i];
    }
    auto lackers = lacks.enumerate.filter!"a.value > 1".array.heapify!"a.value < b.value";
    auto lastOnes = lacks.enumerate.filter!"a.value == 1".array.heapify!"a.value < b.value";
    

    int rest = N - M - 1;
    int[] ans;
    while(!lackers.empty) {
      auto fromRoot = lackers.front;
      lackers.removeFront;

      if (lastOnes.empty) return [-1];

      auto toRoot = lastOnes.front;
      lastOnes.removeFront;

      auto froms = perRoot[fromRoot.index];
      auto tos = perRoot[toRoot.index];
      int from; foreach(k, v; froms) { from = k; break; }
      int to; foreach(k, v; tos) { to = k; break; }

      ans ~= [from, to];
      rest--;
      if (--froms[from] == 0) froms.remove(from);
      if (--tos[to] == 0) tos.remove(to);

      if (--fromRoot.value > 1) lackers.insert(fromRoot); else lastOnes.insert(fromRoot);
    }

    while(!lastOnes.empty) {
      auto fromRoot = lastOnes.front; lastOnes.removeFront;
      if (lastOnes.empty) return [-1];

      auto toRoot = lastOnes.front; lastOnes.removeFront;

      auto froms = perRoot[fromRoot.index];
      auto tos = perRoot[toRoot.index];
      int from; foreach(k, v; froms) { from = k; break; }
      int to; foreach(k, v; tos) { to = k; break; }

      ans ~= [from, to];
      rest--;
    }

    if (rest != 0) return [-1];

    return ans.map!"a + 1".array;
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
