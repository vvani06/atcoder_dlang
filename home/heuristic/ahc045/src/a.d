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

  int testCount = Q / ((N + L - 1) / L);
  int[][][] testGroups = testCount.iota.map!(_ => N.iota.array.randomShuffle(RND).chunks(L).array).array;
  BitArray[] testTrees;
  foreach(t; 0..testCount) {
    BitArray tree = BitArray(false.repeat(N^^2).array);
    foreach(tg; testGroups[t]) {
      if (tg.length == 1) continue;
      
      output("? %s %(%s %)", tg.length, tg);

      int[][] mst = scan!int(2 * tg.length - 2).chunks(2).array;
      foreach(uv; mst) tree[uv[0] * N + uv[1]] = true;
    }
    testTrees ~= tree;
  }
  
  int bestScore;
  Coord[] bestCoords;

  while(!elapsed(1500)) {
    Coord[] coords = RECTS.map!(rc => Coord(uniform(rc[0], rc[1] + 1, RND), uniform(rc[2], rc[3] + 1, RND))).array;
    auto dist = (int i, int j) => coords[i].norm(coords[j]);
    auto cmpDist = (int[] a, int[] b) => dist(a[0], a[1]) < dist(b[0], b[1]);

    int score;
    foreach(groups, testTree; zip(testGroups, testTrees)) {
      UnionFind uf = UnionFind(N);

      foreach(nodes; groups) {
        int[][] pairs;
        foreach(i; 0..nodes.length.to!int - 1) foreach(j; i + 1..nodes.length.to!int) pairs ~= [nodes[i], nodes[j]];

        foreach(pair; pairs.sort!cmpDist) {
          if (uf.same(pair[0], pair[1])) continue;

          uf.unite(pair[0], pair[1]);
          if (testTree[pair[0] * N + pair[1]]) score++;
        }
      }
    }

    if (bestScore.chmax(score)) {
      bestCoords = coords.dup;
    }
  }

  foreach(c; bestCoords) stderr.writefln("%s %s", c.x, c.y);

  Coord[] coords = bestCoords;
  int[][] groups = {
    // auto used = new bool[](N);
    // int[][] ret;
    // foreach(_; 0..M) {
    //   int maxDist, maxNode;
    //   foreach(node; 0..N) {
    //     if (used[node]) continue;

    //     auto maxd = N.iota.filter!(i => !used[i]).map!(i => coords[node].norm(coords[i])).maxElement;
    //     if (maxDist.chmax(maxd)) maxNode = node;
    //   }
    //   ret ~= [maxNode];
    //   used[maxNode] = true;
    // }

    auto minDists = N.iota.map!(base => N.iota.map!(i => base == i ? int.max : coords[base].norm(coords[i])).minElement).array;
    return N.iota.array.sort!((a, b) => minDists[a] < minDists[b])[0..M].map!"[a]".array;
  }();
  auto groupIndicies = G.enumerate(0).array.sort!"a[1] < b[1]";

  struct Edge {
    int base, from, to;

    int norm() {
      return coords[from].norm(coords[to]);
    }
  }

  auto heap = M.iota.map!(m => N.iota.map!(i => Edge(m, groups[m][0], i))).joiner.array.heapify!"a.norm > b.norm";
  bool[] used = new bool[](N);
  foreach(g; groups) used[g[0]] = true;
  UnionFind uf = UnionFind(N);
  Edge[][] edges = new Edge[][](M, 0);

  while(!heap.empty) {
    auto edge = heap.front;
    heap.removeFront;
    if (used[edge.to] || groups[edge.base].length == G[edge.base]) continue;

    edges[edge.base] ~= edge;
    used[edge.to] = true;
    groups[edge.base] ~= edge.to;
    stderr.writeln([[edge.base, edge.from, edge.to, edge.norm]]);
    foreach(next; 0..N) {
      if (!used[next]) heap.insert(Edge(edge.base, edge.to, next));
    }
  }

  output("!");
  foreach(g, es; zip(groups, edges)) {
    output("%(%s %)", g);
    foreach(e; es) {
      output("%(%s %)", [min(e.from, e.to), max(e.from, e.to)]);
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
