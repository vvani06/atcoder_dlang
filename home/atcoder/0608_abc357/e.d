void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto A = scan!int(N);
  // auto A = N.iota.map!(n => uniform(1, N + 1)).array;
  // A.deb;

  auto solve() {
    auto graph = new int[][](N, 0);
    auto revGraph = new int[][](N, 0);
    foreach(i, a; A.enumerate(0)) {
      graph[i] ~= a - 1;
      revGraph[a - 1] ~= i;
    }

    debug {{
      void naive(int cur, ref bool[int] visited) {
        visited[cur] = true;

        auto next = graph[cur][0];
        if (next in visited) return;

        naive(next, visited);
      }
      long ans;
      foreach(i; 0..N) {
        auto visited = new bool[int];
        naive(i, visited);
        // deb(visited.length, visited.keys.map!"a + 1");
        ans += visited.length;
      }
      deb("naive: ", ans);
    }}
    
    auto visited = new bool[](N);
    auto reached = new int[](N);
    int dfs(int cur, int pre) {
      if (visited[cur]) return 0;
      visited[cur] = true;

      int r = 1;
      foreach(next; graph[cur]) {
        if (next != pre) {
          r = max(r, dfs(next, cur) + 1);
        }
      }
      return reached[cur] = r;
    }
    foreach(i; 0..N) {
      if (!visited[i]) dfs(i, i);
    }

    auto uf = UnionFind(N);
    visited[] = false;
    void rdfs(int cur, ref bool[int] route) {
      if (visited[cur]) return;
      visited[cur] = true;
      route[cur] = true;

      foreach(next; revGraph[cur]) {
        if (next in route) {
          foreach(r; route.keys) {
            uf.unite(r, next);
          }
        } else {
          rdfs(next, route);
        }
      }
      route.remove(cur);
    }

    foreach(i; N.iota.array.sort!((a, b) => reached[a] > reached[b])) {
      auto route = new bool[int];
      if (!visited[i]) rdfs(i, route);
    }

    auto sizes = new long[](N);
    foreach(i; 0..N) {
      sizes[uf.root(i)] += 1;
    }
    sizes.deb;

    long[] memo = new long[](N);
    long ansDfs(int cur) {
      if (memo[cur] > 0) return memo[cur];

      auto next = graph[cur][0];
      if (uf.same(cur, next)) {
        return memo[cur] = sizes[uf.root(cur)];
      }

      return memo[cur] = ansDfs(next) + sizes[uf.root(cur)];
    }

    long[] ans;
    foreach(i; 0..N) {
      ans ~= ansDfs(i);
    }
    ans.deb;
    return ans.sum;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std, core.bitop;
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
  int[] roots;
  int[] sizes;
  long[] weights;
 
  this(int size) {
    roots = size.iota.array;
    sizes = 1.repeat(size).array;
    weights = 0L.repeat(size).array;
  }
 
  int root(int x) {
    if (roots[x] == x) return x;

    const root = root(roots[x]);
    weights[x] += weights[roots[x]];
    return roots[x] = root;
  }

  int size(int x) {
    return sizes[root(x)];
  }
 
  bool unite(int x, int y, long w = 0) {
    int rootX = root(x);
    int rootY = root(y);
    if (rootX == rootY) return weights[x] - weights[y] == w;
 
    if (sizes[rootX] < sizes[rootY]) {
      swap(x, y);
      swap(rootX, rootY);
      w *= -1;
    }

    sizes[rootX] += sizes[rootY];
    weights[rootY] = weights[x] - weights[y] - w;
    roots[rootY] = rootX;
    return true;
  }
 
  bool same(int x, int y, int w = 0) {
    int rootX = root(x);
    int rootY = root(y);
 
    return rootX == rootY && weights[rootX] - weights[rootY] == w;
  }
}
