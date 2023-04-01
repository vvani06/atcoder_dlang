void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto XY = scan!int(2 * M).chunks(2);

  auto solve() {
    auto graph = Graph(N);
    foreach(xy; XY) {
      xy[0]--;
      xy[1]--;
      graph.addUnidirectionalEdge(xy);
    }

    auto t = graph.topologicalSort;
    auto s = graph.topologicalSort2;
    // t.deb;
    // s.deb;
    if (t.length != N || s != t) {
      YESNO[false].writeln;
      return;
    }

    YESNO[true].writeln;
    auto ans = new int[](N);
    foreach(i, n; s) {
      ans[n] = i.to!int + 1;
    }
    ans.toAnswerString.writeln;
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

struct Graph {
  long size;
  long[][] g;
  this(long size) {
    this.size = size;
    g = new long[][](size, 0);
  }

  Graph addUnidirectionalEdge(R)(R edge) {
    g[edge[0]] ~= edge[1];
    return this;
  }

  Graph addUnidirectionalEdges(R)(R edges) {
    edges.each!(e => addUnidirectionalEdge(e));
    return this;
  }

  Graph addBidirectionalEdge(R)(R edge) {
    g[edge[0]] ~= edge[1];
    g[edge[1]] ~= edge[0];
    return this;
  }

  Graph addBidirectionalEdges(R)(R edges) {
    edges.each!(e => addBidirectionalEdge(e));
    return this;
  }

  alias tourCallBack = void delegate(long);
  void tour(long start, tourCallBack funcIn = null, tourCallBack funcOut = null) {
    auto visited = new bool[](size);
    void dfs(long cur, long pre) {
      visited[cur] = true;
      if (funcIn) funcIn(cur);
      foreach(n; g[cur]) {
        if (n != pre && !visited[n]) dfs(n, cur);
      }
      if (funcOut) funcOut(cur);
    }
    dfs(start, -1);
  }

  long[] topologicalSort() {
    auto depth = new long[](size);
    foreach(e; g) foreach(p; e) depth[p]++;

    auto q = heapify!"a > b"(new long[](0));
    foreach(i; 0..size) if (depth[i] == 0) q.insert(i);

    long[] sorted;
    while(!q.empty) {
      auto p = q.front;
      q.removeFront;
      foreach(n; g[p]) {
        depth[n]--;
        if (depth[n] == 0) q.insert(n);
      }

      sorted ~= p;
    }

    return sorted;
  }

  long[] topologicalSort2() {
    auto depth = new long[](size);
    foreach(e; g) foreach(p; e) depth[p]++;

    auto q = heapify!"a < b"(new long[](0));
    foreach(i; 0..size) if (depth[i] == 0) q.insert(i);

    long[] sorted;
    while(!q.empty) {
      auto p = q.front;
      q.removeFront;
      foreach_reverse(n; g[p]) {
        depth[n]--;
        if (depth[n] == 0) q.insert(n);
      }

      sorted ~= p;
    }

    return sorted;
  }
}
