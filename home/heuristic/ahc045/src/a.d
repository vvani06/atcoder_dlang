void main() { runSolver(); }

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
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
  else fn().writeln;}
void runSolver() {
  problem();}
void output(T ...)(T t) {
  // debug stderr.writefln(t);
  stdout.writefln(t);
  stdout.flush(); }
void deb(T ...)(T t){ debug { stderr.write("# "); stderr.writeln(t); }}
void debf(T ...)(T t){ debug { stderr.write("# "); stderr.writefln(t); }}
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
  }}
struct UnionFindExtra { UnionFindExtra merge(UnionFindExtra other) { return UnionFindExtra(); } }
alias UnionFind = UnionFindWith!UnionFindExtra;

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto RND = Xorshift(0);

  struct Coord {
    int x, y;

    int dist(Coord other) {
      auto dx = x - other.x;
      auto dy = y - other.y;
      return (dx*dx + dy*dy).to!float.sqrt.to!int;
    }
  }

  int N = scan!int;
  int M = scan!int;
  int Q = scan!int;
  int L = scan!int;
  int W = scan!int;
  int[] G = scan!int(M);
  int[][] RECTS = scan!int(4 * N).chunks(4).array;
  int[] V = RECTS.map!(r => r[1] + r[3] - r[0] - r[2]).array;

  Coord[] coords = RECTS.map!(r => Coord(r[0..2].sum / 2, r[2..4].sum / 2)).array;

  int[800^^2] distancesArray;
  foreach(i; 0..N) foreach(j; 0..N) distancesArray[i*N + j] = coords[i].dist(coords[j]);

  int CALC_BOUND = 8000;
  int NEIGHBOR_LIMIT = L;
  int[][] neighbors = new int[][](N, 0);
  int[][] neighborsByNear = new int[][](N, 0);
  foreach(i; 0..N) foreach(j; i+1..N) {
    // if (coords[i].dist(coords[j]) <= CALC_BOUND) {
      neighbors[i] ~= j;
      neighbors[j] ~= i;
    // }
  }
  foreach(i; 0..N) {
    neighborsByNear[i] = neighbors[i].sort!((a, b) => coords[i].dist(coords[a]) < coords[i].dist(coords[b]))[0..NEIGHBOR_LIMIT].array;
    neighbors[i] = neighborsByNear[i].sort.array;
  }

  // モンテカルロで頂点間の距離を推定
  enum MONT_TIMES = 200; {
    int[][] distances = new int[][](N, N); {
      foreach(_; 0..MONT_TIMES) {
        auto rx = RECTS.map!(r => uniform(r[0], r[1] + 1, RND)).array;
        auto ry = RECTS.map!(r => uniform(r[2], r[3] + 1, RND)).array;
        foreach(i; 0..N) foreach(j; neighbors[i].assumeSorted.upperBound(i)) {
          auto dx = abs(rx[i] - rx[j]);
          auto dy = abs(ry[i] - ry[j]);
          distances[i][j] += (dx*dx + dy*dy).to!float.sqrt.to!int;
        }
      }
      foreach(i; 0..N) foreach(j; i + 1..N) {
        distances[j][i] = distances[i][j];
      }
    }
    foreach(i; 0..N) foreach(j; 0..N) {
      auto d = distances[min(i, j)][max(i, j)];
      if (d > 0) distancesArray[i*N + j] = d / MONT_TIMES;
    }
  }

  struct Edge {
    int from, to;

    inout int norm() {
      return distancesArray[from*N + to];
    }

    int[] asAns() {
      return [min(from, to), max(from, to)];
    }

    inout opCmp(inout Edge other) {
      return cmp(
        [norm(), from, to],
        [other.norm(), other.from, other.to],
      );
    }

    string toString() {
      return format("Edge(%s -> %s) / cost: %s", from, to, norm());
    }

    int asId() {
      return min(from, to) * N + max(from, to);
    }
  }

  Edge[] allEdges(int[] nodes = [-1]) { 
    if (nodes == [-1]) nodes = N.iota.array;

    Edge[] ret;
    int size = nodes.length.to!int;
    foreach(i; 0..size - 1) foreach(j; i + 1..size) {
      ret ~= Edge(nodes[i], nodes[j]);
    }
    return ret;
  }

  Edge[] oracle(int[] set) {
    output("? %s %(%s %)", set.length, set);
    return scan!int(set.length * 2 - 2).chunks(2).map!(a => Edge(a[0], a[1])).array;
  }

  Edge[] partialMST(int[] set) {
    auto uf = UnionFind(N);
    Edge[] ret = new Edge[](0);

    for(auto heap = allEdges(set).heapify!"a > b"; !heap.empty;) {
      auto cur = heap.front; heap.removeFront;
      if (uf.same(cur.from, cur.to)) continue;

      uf.unite(cur.from, cur.to);
      ret ~= cur;
    }
    return ret;
  }

  auto perfectQueryCount = G.count!(g => g >= 3 && g <= L).to!int;

  foreach(base; N.iota.array.sort!((a, b) => V[a] > V[b])[0..Q - perfectQueryCount]) {
    auto qset = base ~ neighborsByNear[base][0..L - 1];

    auto ret = oracle(qset).redBlackTree;
    auto pmst = partialMST(qset).redBlackTree;

    auto ratio = W.to!real / 4100.0;
    foreach(e; ret) distancesArray[e.asId()] = (distancesArray[e.asId()].to!real * (1.0 - ratio)).to!int;
    // foreach(e; ret.array.filter!(e => e in pmst)) distancesArray[e.asId()] = (distancesArray[e.asId()].to!real * (1.0 - ratio)).to!int;
    foreach(e; pmst.array.filter!(e => e in ret)) distancesArray[e.asId()] = (distancesArray[e.asId()].to!real * (1.0 + ratio)).to!int;
  }
  
  UnionFind stepTree;

  if (M >= 200) {
    stepTree = {
      auto uf = UnionFind(N);

      int[int] restPerSize = cast(int[int])G.dup.sort.group.assocArray;
      int[] rests = new int[](N + 2);
      foreach_reverse(i; 0..N + 1) rests[i] = rests[i + 1] + restPerSize.get(i, 0);
      auto heap = allEdges().heapify!"a > b";

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
  } else {
    stepTree = {
      auto uf = UnionFind(N);
      auto tree = new int[][](N, 0).map!redBlackTree.array;
      auto heap = allEdges().filter!(e => e.norm <= CALC_BOUND).array.heapify!"a > b";

      auto edges = new Edge[](0).redBlackTree;
      while(!heap.empty) {
        auto edge = heap.front;
        heap.removeFront;
        if (uf.same(edge.from, edge.to)) continue;

        uf.unite(edge.from, edge.to);
        edges.insert(edge);
        tree[edge.from].insert(edge.to);
        tree[edge.to].insert(edge.from);
      }

      bool[] fixed = new bool[](N);
      foreach(reqSize; G.dup.sort!"a > b"[0..$ - 1]) {
        int bestSize, bestDist;
        int bestNode, bestFrom;

        int[] treeSizes = new int[](N);
        int dfs(int cur, int pre) {
          int ret = 1;
          foreach(next; tree[cur]) {
            if (next != pre) ret += dfs(next, cur);
          }

          if (ret <= reqSize && cur != pre && (bestSize.chmax(ret) || (bestSize == ret && bestDist.chmax(Edge(cur, pre).norm())))) {
            bestDist = Edge(cur, pre).norm();
            // Edge(cur, pre).deb;
            bestNode = cur;
            bestFrom = pre;
          }
          return treeSizes[cur] = ret;
        }

        foreach(i; 0..N) {
          if (!fixed[i] && treeSizes[i] == 0) dfs(i, i);
        }

        // [reqSize, bestSize, bestNode].deb;
        // auto removeEdge = tree[bestNode].array.map!(t => Edge(bestNode, t)).maxElement!"a.norm";
        auto removeEdge = Edge(min(bestFrom, bestNode), max(bestFrom, bestNode));
        edges.removeKey(removeEdge);
        // [removeEdge].deb;
        tree[removeEdge.from].removeKey(removeEdge.to);
        tree[removeEdge.to].removeKey(removeEdge.from);

        int[] nodes;
        void fix(int cur, int pre) {
          fixed[cur] = true;
          nodes ~= cur;
          foreach(next; tree[cur]) {
            if (next != pre) fix(next, cur);
          }
        }
        fix(bestNode, bestNode);

        int[] degrees = new int[](N);
        foreach(e; edges) {
          degrees[e.from]++;
          degrees[e.to]++;
        }

        int rest = reqSize - bestSize;
        while (rest > 0) {
          auto freeNodes = N.iota.filter!(i => !fixed[i] && degrees[i] == 1).array;
          auto heap2 = new Edge[](0).heapify!"a > b";
          foreach(from; nodes) foreach(to; freeNodes) {
            auto edge = Edge(from, to);
            if (edge.norm <= CALC_BOUND) heap2.insert(edge);
          }

          foreach(edge; heap2) {
            if (fixed[edge.to]) continue;

            fixed[edge.to] = true;
            nodes ~= edge.to;
            auto rem = edges.array.filter!(e => e.from == edge.to || e.to == edge.to).front;
            edges.removeKey(rem);
            tree[rem.from].removeKey(rem.to);
            tree[rem.to].removeKey(rem.from);
            degrees[rem.from]--;
            degrees[rem.to]--;

            edges.insert(edge);
            tree[edge.from].insert(edge.to);
            tree[edge.to].insert(edge.from);
            
            // deb("remove: ", rem);
            // deb("add: ", edge);
            if (--rest == 0) break;
          }
        }
      }

      // edges.array.length.deb;
      auto finalTree = UnionFind(N);
      foreach(e; edges) finalTree.unite(e.from, e.to);
      return finalTree;
    }();
  }

  class State {
    RedBlackTree!(int)[] nodes;
    int[] degrees;
    int[] at;
    int[] costs;
    RedBlackTree!Edge edges;
    RedBlackTree!(Edge)[] edgesPerGroup;

    this(UnionFind tree) {
      int[][int] nodesPerRoot;
      foreach(i; 0..N) nodesPerRoot[tree.root(i)] ~= i;

      nodes = M.iota.map!(_ => new int[](0).redBlackTree).array; {
        int[][int] groupIdsPerSize;
        foreach(i, g; G.enumerate(0)) groupIdsPerSize[g] ~= i;
        int[int] groupCountPerSize;
        
        foreach(nds; nodesPerRoot.values) {
          int size = nds.length.to!int;
          
          nodes[groupIdsPerSize[size][groupCountPerSize.get(size, 0)]].insert(nds);
          groupCountPerSize[size]++;
        }
      }

      degrees = new int[](N);
      at = new int[](N);
      costs = new int[](M);

      auto uf = UnionFind(N);
      edges = new Edge[](0).redBlackTree;
      edgesPerGroup = M.iota.map!(_ => new Edge[](0).redBlackTree).array;
      foreach(gid, ns; nodes.enumerate(0)) {
        auto arr = ns.array;
        foreach(i; arr) at[i] = gid;

        int merged;
        for(auto heap = allEdges(arr).heapify!"a > b"; !heap.empty;) {
          auto cur = heap.front;
          heap.removeFront;
          if (uf.same(cur.from, cur.to)) continue;

          uf.unite(cur.from, cur.to);
          edges.insert(cur);
          edgesPerGroup[gid].insert(cur);
          degrees[cur.from]++;
          degrees[cur.to]++;
          costs[gid] += cur.norm();
          if (++merged == G[gid] - 1) break;
        }
      }
    }

    void outputAsAns() {
      output("!");
      foreach(id; 0..M) {
        output("%(%s %)", nodes[id].array);
        foreach(e; edgesPerGroup[id]) {
          output("%(%s %)", e.asAns());
        }
      }
    }

    int[] swappable(Edge e) {
      return [e.from, e.to].filter!(i => degrees[i] == 1).array;
    }

    int[] nearestOthers(int gid, int except) {
      int[][] dists;
      foreach(i; N.iota.filter!(i => !(i in nodes[gid]))) {
        int mini = int.max;
        foreach(j; nodes[gid]) {
          if (j == except) continue;

          mini = min(mini, Edge(i, j).norm());
        }
        dists ~= [i, mini];
      }
      return dists.sort!"a[1] < b[1]".map!"a[0]".array;
    }

    int testSwap(int p, int q) {
      if (at[p] == at[q]) return 0;

      auto np = nodes[at[p]].dup;
      np.removeKey(p);
      np.insert(q);
      auto cp = calcCost(np);

      auto nq = nodes[at[q]].dup;
      nq.removeKey(q);
      nq.insert(p);
      auto cq = calcCost(nq);

      return (cp - costs[at[p]]) + (cq - costs[at[q]]);
    }

    int calcCost(RedBlackTree!int testNodes) {
      int ret;
      int merged;
      auto size = testNodes.array.length;

      auto uf = UnionFind(N);
      for(auto heap = allEdges(testNodes.array).heapify!"a > b"; !heap.empty;) {
        auto cur = heap.front;
        heap.removeFront;
        if (uf.same(cur.from, cur.to)) continue;

        uf.unite(cur.from, cur.to);
        ret += cur.norm();
        if (++merged == size - 1) break;
      }
      return ret;
    }

    void swap(int p, int q) {
      auto ap = at[p];
      auto aq = at[q];
      if (ap == aq) return;

      nodes[ap].removeKey(p);
      nodes[ap].insert(q);
      nodes[aq].removeKey(q);
      nodes[aq].insert(p);
      build(ap);
      build(aq);
    }

    void build(int gid) {
      auto arr = nodes[gid].array;
      foreach(i; arr) {
        at[i] = gid;
        degrees[i] = 0;
      }
      costs[gid] = 0;
      
      edges.removeKey(edgesPerGroup[gid].array);
      edgesPerGroup[gid].clear;

      int merged;
      auto uf = UnionFind(N);
      for(auto heap = allEdges(arr).heapify!"a > b"; !heap.empty;) {
        auto cur = heap.front;
        heap.removeFront;
        if (uf.same(cur.from, cur.to)) continue;

        uf.unite(cur.from, cur.to);
        edges.insert(cur);
        edgesPerGroup[gid].insert(cur);
        degrees[cur.from]++;
        degrees[cur.to]++;
        costs[gid] += cur.norm();
        if (++merged == G[gid] - 1) break;
      }
    }

    void oraclate() {
      // if (M < 25) return;

      auto uf = UnionFind(N);
      foreach(id; 0..M) {
        if (G[id] < 3 || G[id] > L) continue;
        // if (G[id] > L * 5 && W < 1500) continue;

        auto rest = nodes[id].dup;
        auto visited = new int[](0).redBlackTree;

        Edge[] rep;
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

          auto heap = new Edge[](0).heapify!"a > b";
          foreach(f; pair) {
            foreach(t; visited.empty ? nodes[id] : visited) {
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
            rep ~= Edge(e[0], e[1]);
            rest.removeKey(e[0], e[1]);
            visited.insert([e[0], e[1]]);
          }
        }

        if (rep.length == G[id] - 1) {
          edges.removeKey(edgesPerGroup[id].array);
          edgesPerGroup[id].clear;
          foreach(e; rep) {
            edges.insert(e);
            edgesPerGroup[id].insert(e);
          }
        }
      }
    }
  }

  deb((MonoTime.currTime() - StartTime).total!"msecs", " msecs");
  auto state = new State(stepTree);

  auto boundary = 0;
  while(!elapsed(1500)) {
    int tested;
    int globalBest;
    foreach_reverse(swapEdge; state.edges) {
      if (state.swappable(swapEdge).empty) continue;

      auto from = state.swappable(swapEdge).choice(RND);
      int bestTo;
      int best = int.max;
      foreach(to; state.nearestOthers(state.at[from], from)[0..min($, 30)]) {
        if (best.chmin(state.testSwap(from, to))) {
          bestTo = to;
        }
      }

      globalBest = min(globalBest, best);
      if (best < boundary) {
        state.swap(from, bestTo);
        debf("swap: %s => %s", from, bestTo);
        break;
      }

      if (++tested >= 200 || elapsed(1500)) break;
    }
    if (globalBest >= boundary || elapsed(1500)) break;
  }
  deb((MonoTime.currTime() - StartTime).total!"msecs", " msecs");

  state.oraclate();
  state.outputAsAns();
}
