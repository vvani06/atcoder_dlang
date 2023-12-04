void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto K = scan!long;
  alias Edge = Tuple!(int, "from", int, "to", long, "cost");
  auto E = scan!long(3 * M).chunks(3).map!(e => Edge(e[0].to!int - 1, e[1].to!int - 1, e[2]));

  auto solve() {
    auto graph = new int[][](N, 0);
    foreach(i, e; E.enumerate(0)) {
      graph[e.from] ~= i;
      graph[e.to] ~= i;
    }
    
    long dfs(UnionFind uf, int node, long cost) {
      if (uf.size(0) == N) return cost;

      long ret = long.max;
      foreach(e; graph[node]) {
        if (uf.same(E[e].from, E[e].to)) continue;

        auto connected =  uf.dup;
        connected.unite(E[e].from, E[e].to);
        ret = min(ret, dfs(connected, node + 1, (cost + E[e].cost) % K));
      }
      return ret;
    }

    return dfs(UnionFind(N), 0, 0); 
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

struct UnionFind {
  int[] parent;
  int[] sizes;
 
  this(int size) {
    parent = size.iota.array;
    sizes = 1.repeat(size).array;
  }
 
  int root(int x) {
    if (parent[x] == x) return x;
    return parent[x] = root(parent[x]);
  }

  int size(int x) {
    return sizes[root(x)];
  }
 
  int unite(int x, int y) {
    int rootX = root(x);
    int rootY = root(y);
 
    if (rootX == rootY) return rootY;
 
    if (sizes[rootX] < sizes[rootY]) {
      sizes[rootY] += sizes[rootX];
      return parent[rootX] = rootY;
    } else {
      sizes[rootX] += sizes[rootY];
      return parent[rootY] = rootX;
    }
  }
 
  bool same(int x, int y) {
    int rootX = root(x);
    int rootY = root(y);
 
    return rootX == rootY;
  }

  UnionFind dup() {
    auto ret = UnionFind(parent.length.to!int);
    ret.parent = parent.dup;
    ret.sizes = sizes.dup;
    return ret;
  }
}
