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

  auto CALC_BOUND = max(3500, W * 2);
  Coord[] coords = RECTS.map!(r => Coord(r[0..2].sum / 2, r[2..4].sum / 2)).array;
  int[][] distances = new int[][](N, N); {
    bool[][] overed = new bool[][](N, N);
    foreach(i; 0..N) foreach(j; i + 1..N) {
      if (coords[i].norm(coords[j]) > CALC_BOUND^^2) {
        distances[i][j] = distances[j][i]  = (coords[i].norm(coords[j])).to!float.sqrt.to!int;
        overed[i][j] = true;
      }
    }

    enum MONT_TIMES = 1000;
    foreach(_; 0..MONT_TIMES) {
      auto rx = RECTS.map!(r => uniform(r[0], r[1] + 1, RND)).array;
      auto ry = RECTS.map!(r => uniform(r[2], r[3] + 1, RND)).array;
      foreach(i; 0..N) foreach(j; i + 1..N) {
        if (overed[i][j]) continue;

        auto dx = abs(rx[i] - rx[j]);
        auto dy = abs(ry[i] - ry[j]);
        distances[i][j] += (dx*dx + dy*dy).to!float.sqrt.to!int;
      }
    }
    foreach(i; 0..N) foreach(j; i + 1..N) {
      if (overed[i][j]) continue;
      
      distances[i][j] /= MONT_TIMES;
      distances[j][i] = distances[i][j];
    }
  }

  struct Edge {
    int from, to;

    inout int norm() {
      return distances[from][to];
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
  int[] at = new int[](N);
  foreach(i; 0..N) {
    nodes[stepTree.root(i)] ~= i;
    at[i] = stepTree.root(i);
    if (stepTree.root(i) == i) ans[stepTree.size(i)] ~= i;
  }

  class State {
    RedBlackTree!(int)[] nodes;
    int[] nodeAt;
    RedBlackTree!(int, "a < b", true)[] l, t;
    RedBlackTree!(int, "a < b", true)[] r, b;
    int[][int] ansGroup;
    int[] groupIds;
    int cost;

    int[][] operations;

    State dup() {
      auto uf = UnionFind(N);
      foreach(t; nodes) {
        if (!t.empty) foreach(n; t.array) uf.unite(t.front, n);
      }
      return new State(uf);
    }

    void remove(int node, int group) {
      nodes[group].removeKey(node);
      nodeAt[node] = -1;
      l[group].removeKey(RECTS[node][0]);
      r[group].removeKey(RECTS[node][1]);
      t[group].removeKey(RECTS[node][2]);
      b[group].removeKey(RECTS[node][3]);
    }

    void add(int node, int group) {
      nodes[group].insert(node);
      nodeAt[node] = group;
      l[group].insert(RECTS[node][0]);
      r[group].insert(RECTS[node][1]);
      t[group].insert(RECTS[node][2]);
      b[group].insert(RECTS[node][3]);
    }

    void swap(int p, int q) {
      auto ap = nodeAt[p];
      auto aq = nodeAt[q];
      if (ap == aq) return;

      cost -= calcCostAt(ap);
      cost -= calcCostAt(aq);
      remove(p, ap);
      add(p, aq);
      remove(q, aq);
      add(q, ap);
      cost += calcCostAt(ap);
      cost += calcCostAt(aq);
      operations ~= [p, q];
    }

    void reset() {
      foreach_reverse(op; operations) {
        swap(op[0], op[1]);
      }
      commit();
    }

    void commit() {
      operations.length = 0;
    }

    int calcCostAt(int i) {
      if (nodes[i].length <= 1) return 0;

      return r[i].back - l[i].front + b[i].back - t[i].front;
    }

    int calcCost() {
      return N.iota.map!(i => calcCostAt(i)).sum;
    }

    int worstGroup() {
      int ret, worst;
      foreach(g; groupIds) {
        if (worst.chmax(calcCostAt(g))) ret = g;
      }
      return ret;
    }

    this() {
      nodes = new int[][](N, 0).map!redBlackTree.array;
      nodeAt = new int[](N);
      l = new int[][](N, 0).map!(arr => arr.redBlackTree!true).array;
      r = new int[][](N, 0).map!(arr => arr.redBlackTree!true).array;
      t = new int[][](N, 0).map!(arr => arr.redBlackTree!true).array;
      b = new int[][](N, 0).map!(arr => arr.redBlackTree!true).array;
    }

    this(UnionFind uf) {
      this();
      foreach(i; 0..N) {
        add(i, uf.root(i));
        if (uf.root(i) == i) ansGroup[uf.size(i)] ~= i;
      }
      groupIds = ansGroup.values.joiner.array;
      cost = calcCost();
    }
  }

  auto state = new State(stepTree);
  auto bestCost = state.cost;

  // 頂点集合を焼きなまし
  // if (M > 1) while (!elapsed(1800)) {
  //   auto wg = state.worstGroup();
  //   auto swapper = state.nodes[wg].array.choice(RND);
  //   auto swappee = uniform(0, N, RND);
  //   state.swap(swapper, swappee);
  //   if (bestCost.chmin(state.cost)) {
  //     state.commit();
  //     // stderr.writefln("commit: %s", bestCost);
  //   } else if (state.operations.length >= 8) {
  //     state.reset();
  //     // stderr.writefln("reset: %s", state.cost);
  //   }
  // }

  state.reset();
  nodes = state.nodes.map!array.array;
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
  
  // 占い結果で仮装木を上書き
  if (M >= 15) foreach(id; ans.values.joiner) {
    auto size = nodes[id].length.to!int;
    if (size < 3) continue;

    edges[id].length = 0;
    auto rest = nodes[id].redBlackTree;
    auto visited = new int[](0).redBlackTree;

    auto uf = UnionFind(N);
    while(!rest.empty) {
      int[] pair;
      if (rest.array.length == 1) {
        pair = [rest.front];
      } else {
        auto arr = rest.array;
        int nearest = int.max;
        foreach(i; 0..arr.length - 1) foreach(j; i + 1..arr.length) {
          auto p = arr[i];
          auto q = arr[j];
          if (nearest.chmin(Edge(p, q).norm())) {
            pair = [p, q];
          }
        }
      }

      auto heap = new Edge[](0).heapify!"a.norm > b.norm";
      foreach(f; pair) {
        foreach(t; visited.empty ? nodes[id] : visited.array) {
          if (pair.canFind(t)) continue;

          heap.insert(Edge(f, t));
        }
      }

      auto search = pair;
      auto neigh = pair.redBlackTree;
      foreach(e; heap) {
        if (!(e.from in neigh)) {
          search ~= e.from;
          neigh.insert(e.from);
        }
        if (search.length >= L) break;

        if (!(e.to in neigh)) {
          search ~= e.to;
          neigh.insert(e.to);
        }
        if (search.length >= L) break;
      }

      auto qs = search.length.to!int;
      output("? %s %(%s %)", qs, search);
      foreach(e; scan!int(2 * qs - 2).chunks(2)) {
        if (uf.same(e[0], e[1])) continue;

        uf.unite(e[0], e[1]);
        edges[id] ~= Edge(e[0], e[1]);
        rest.removeKey(e[0], e[1]);
        visited.insert([e[0], e[1]]);
      }
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
