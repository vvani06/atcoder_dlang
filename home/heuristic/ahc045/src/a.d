void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto RND = Xorshift(0);

  struct Coord {
    int x, y;

    int norm(Coord other) {
      auto dx = x - other.x;
      auto dy = y - other.y;
      return dx*dx + dy*dy;
    }
  }

  int N = scan!int;
  int M = scan!int;
  int Q = scan!int;
  int L = scan!int;
  int W = scan!int;
  int[] G = scan!int(M);
  int[][] RECTS = scan!int(4 * N).chunks(4).array;

  Coord[] coords = RECTS.map!(r => Coord(r[0..2].sum / 2, r[2..4].sum / 2)).array;
  
  struct Edge {
    int from, to;

    inout int norm() {
      return coords[from].norm(coords[to]);
    }

    int[] asAns() {
      return [min(from, to), max(from, to)];
    }
  }
  
  UnionFind stepTree = {
    auto uf = UnionFind(N);

    int[int] restPerSize = cast(int[int])G.dup.sort.group.assocArray;
    int[] rests = new int[](N + 2);
    foreach_reverse(i; 0..N + 1) rests[i] = rests[i + 1] + restPerSize.get(i, 0);
    auto heap = (N - 1).iota.map!(i => iota(i + 1, N).map!(j => Edge(i, j))).joiner.array.heapify!"a.norm > b.norm";

    while(!heap.empty) {
      auto edge = heap.front;
      heap.removeFront;

      if (uf.same(edge.from, edge.to)) continue;
      if (uf.size(edge.from) != 1 && uf.size(edge.to) != 1) continue;
      if (rests[uf.size(edge.from) + uf.size(edge.to)] <= 0) continue;

      restPerSize[uf.size(edge.from)]++;
      restPerSize[uf.size(edge.to)]++;
      uf.unite(edge.from, edge.to);
      rests[uf.size(edge.to)]--;
    }
    return uf;
  }();

  int[][int] ans;
  int[][] nodes = new int[][](N, 0);
  foreach(i; 0..N) {
    nodes[stepTree.root(i)] ~= i;
    if (stepTree.root(i) == i) ans[stepTree.size(i)] ~= i;
  }

  Edge[][] edges = new Edge[][](N, 0);
  auto partialTree = UnionFind(N);
  foreach(n; 0..N) {
    auto g = nodes[n].length.to!int;
    auto heap = (g - 1).iota.map!(i => iota(i + 1, g).map!(j => Edge(nodes[n][i], nodes[n][j]))).joiner.array.heapify!"a.norm > b.norm";
    while(!heap.empty) {
      auto cur = heap.front;
      heap.removeFront;
      if (partialTree.same(cur.from, cur.to)) continue;

      edges[n] ~= cur;
      partialTree.unite(cur.from, cur.to);
    }
  }
  
  output("!");
  foreach(g; G) {
    auto id = ans[g].back;
    ans[g].length = ans[g].length - 1;

    output("%(%s %)", nodes[id]);
    foreach(e; edges[id]) {
      output("%(%s %)", e.asAns());
    }
  }
}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
// void deb(T ...)(T t){ debug {  }}
T[] divisors(T)(T n) { T[] ret; for (T i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
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
  problem();
}
enum YESNO = [true: "Yes", false: "No"];
void output(T ...)(T t) {
  debug stderr.writefln(t);
  stdout.writefln(t);
  stdout.flush();
}

struct UnionFindWith(T = UnionFindExtra) {
  int[] roots;
  int[] sizes;
  long[] weights;
  T[] extras;
 
  this(int size) {
    roots = size.iota.array;
    sizes = 1.repeat(size).array;
    weights = 0L.repeat(size).array;
    extras = new T[](size);
  }
 
  this(int size, T[] ex) {
    roots = size.iota.array;
    sizes = 1.repeat(size).array;
    weights = 0L.repeat(size).array;
    extras = ex.dup;
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

  T extra(int x) {
    return extras[root(x)];
  }

  T setExtra(int x, T t) {
    return extras[root(x)] = t;
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
    extras[rootX] = extras[rootX].merge(extras[rootY]);
    roots[rootY] = rootX;
    return true;
  }
 
  bool same(int x, int y, int w = 0) {
    int rootX = root(x);
    int rootY = root(y);
 
    return rootX == rootY && weights[rootX] - weights[rootY] == w;
  }

  auto dup() {
    auto dupe = UnionFindWith!T(roots.length.to!int);
    dupe.roots = roots.dup;
    dupe.sizes = sizes.dup;
    dupe.weights = weights.dup;
    dupe.extras = extras.dup;
    return dupe;
  }
}

struct UnionFindExtra { UnionFindExtra merge(UnionFindExtra other) { return UnionFindExtra(); } }
alias UnionFind = UnionFindWith!UnionFindExtra;
