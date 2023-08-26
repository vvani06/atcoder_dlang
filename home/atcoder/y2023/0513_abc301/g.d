void main() { runSolver(); }

void problem() {
  struct Edge {
    int id, u, v;
    long w;
  }
  struct LCA {
    int depth = 10000000;
    int node = -1;

    int opCmp(LCA other) {
      return other.depth > depth ? -1 : 1;
    }
  }

  auto N = scan!int;
  auto E = (N - 1).iota.map!(i => Edge(i, scan!int - 1, scan!int - 1, scan!long)).array;
  auto Q = scan!int;

  auto solve() {
    auto graph = new Edge[][](N, 0);
    foreach(e; E) {
      graph[e.u] ~= e;
      graph[e.v] ~= Edge(e.id, e.v, e.u, e.w);
    }
    // graph.each!deb;

    auto tourIn = new int[](N);
    auto tourOut = new int[](N);
    auto edgeIn = new int[](N - 1);
    auto edgeOut = new int[](N - 1);
    auto routes = new int[](N * 2);
    auto costTree = SegTree!("a + b", long)(new long[](2 * N));
    auto lcaTree = SegTree!("min(a, b)", LCA)(new LCA[](2 * N), LCA.init);

    int tourNum, depth;
    void tour(int cur, int pre, int ei) {
      depth++;
      lcaTree.update(tourNum, LCA(depth, pre));

      routes[tourNum] = cur;
      if (ei >= 0) {
        edgeIn[ei] = tourNum;
        costTree.update(tourNum, E[ei].w);
      }
      tourIn[cur] = tourNum++;
      foreach(e; graph[cur]) {
        if (e.v == pre) continue;

        tour(e.v, cur, e.id);
      }

      routes[tourNum] = cur;
      if (ei >= 0) {
        edgeOut[ei] = tourNum;
        costTree.update(tourNum, -E[ei].w);
      }
      tourOut[cur] = tourNum++;
      depth--;
    }
    tour(0, 0, -1);
    // routes.deb;
    // tourIn.deb;
    // tourOut.deb;
    // edgeIn.deb;
    // edgeOut.deb;
    // segtree.data[segtree.data.length/2 .. $].deb;

    foreach(_; 0..Q) {
      if (scan!int == 1) {
        auto i = scan!int - 1;
        auto w = scan!long;
        costTree.update(edgeIn[i], w);
        costTree.update(edgeOut[i], -w);
      } else {
        auto u = scan!int - 1;
        auto v = scan!int - 1;

        auto l = tourIn[u];
        auto r = tourIn[v];
        if (l > r) swap(l, r);
        auto ans = costTree.sum(0, l + 1) + costTree.sum(0, r + 1);

        auto lca = lcaTree.sum(l + 1, r + 1);
        auto m = lca.node == -1 ? l : tourIn[lca.node];
        // [l, r, lca.node].deb;
        // lca.deb;
        ans -= costTree.sum(0, m + 1) * 2;
        ans.writeln;
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