void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);

  int N = scan!int;
  int M = scan!int;
  int TN = scan!int;
  int LA = scan!int;
  int LB = scan!int;
  int[][] UV = scan!int(2 * M).chunks(2).array;
  int[] T = scan!int(TN);
  int[][] XY = scan!int(2 * N).chunks(2).array;

  struct HashValue {
    int count, length, index;
    long hash;

    inout long[] cmpValues() {
      return [count * length^^5, count, length, hash];
    }

    inout int opCmp(inout HashValue other) {
      return cmp(
        cmpValues(),
        other.cmpValues(),
      );
    }
  }

  long[][] calcDistances(int[][] graph, long[] nodeCosts) {
    long[][] ret = new long[][](N, N);
    int[][] nexts = new int[][](N, N);

    foreach(to; 0..N) {
      int[] froms = new int[](N);
      froms[] = -1;
      froms[to] = to;

      long[] costMemo = new long[](N);
      costMemo[] = long.max / 3;
      costMemo[to] = 0;

      alias CostNode = Tuple!(int, "node", int, "from", long, "cost");

      for(auto queue = [CostNode(to, to, 0)].heapify!"a.cost > b.cost"; !queue.empty;) {
        auto cur = queue.front;
        queue.removeFront;
        if (cur.cost != costMemo[cur.node]) continue;

        froms[cur.node] = cur.from;
        foreach(next; graph[cur.node]) {
          if (froms[next] != -1) continue;

          long cost = cur.cost + nodeCosts[next];
          if (costMemo[next].chmin(cost)) {
            queue.insert(CostNode(next, cur.node, cost));
          }
        }
      }
      foreach(from; 0..N) {
        nexts[from][to] = froms[from];
        ret[from][to] = costMemo[from];
      }
    }

    return ret;
  }

  final class Simulator {
    string name;
    int[][] graph;
    long[] nodeCosts;

    int[] route;

    this(string name, int[][] g, long[] costs) {
      this.name = name;
      graph = g.map!"a.dup".array;
      nodeCosts = costs.dup;

      provisionRoute();

      if (LA * (24 - LB) >= 14_000) {
        provisionSignal2();
      } else {
        provisionSignal();
      }
    }

    void provisionRoute() {
      int[][] nexts = new int[][](N, N);

      foreach(to; 0..N) {
        int[] froms = new int[](N);
        froms[] = -1;
        froms[to] = to;

        long[] costMemo = new long[](N);
        costMemo[] = long.max / 3;
        costMemo[to] = 0;

        alias CostNode = Tuple!(int, "node", int, "from", long, "cost");

        for(auto queue = [CostNode(to, to, 0)].heapify!"a.cost > b.cost"; !queue.empty;) {
          auto cur = queue.front;
          queue.removeFront;
          if (cur.cost != costMemo[cur.node]) continue;

          froms[cur.node] = cur.from;
          foreach(next; graph[cur.node]) {
            if (froms[next] != -1) continue;

            long cost = cur.cost + nodeCosts[next];
            if (costMemo[next].chmin(cost)) {
              queue.insert(CostNode(next, cur.node, cost));
            }
          }
        }
        foreach(from; 0..N) {
          nexts[from][to] = froms[from];
        }
      }

      int cur = 0;
      foreach(t; T) {
        while(cur != t) {
          cur = nexts[cur][t];
          route ~= cur;
        }
      }
    }

    int[] signals;
    int[long][] indiciesForSignalHash;
    int[] indiciesForSignal;
    HashValue[] insertedSignal;

    void provisionSignal() {
      signals.length = 0;
      indiciesForSignalHash = new int[long][](LB + 1);
      indiciesForSignal = new int[](N);

      long[][] hashes = new long[][](LB + 1, route.length);
      int[long][] hashCount = new int[long][](LB + 1);
      int[long][] hashIndex = new int[long][](LB + 1);
      auto hashTree = new HashValue[](0).redBlackTree!"a > b";
      
      foreach(l; 1..LB + 1) {
        foreach(i; 0..route.length) {
          auto uniqueNodes = route[i..min($, i + l)].dup.sort.uniq;
          long hash;
          foreach(n; uniqueNodes) hash ^= n.hashOf(seed);
          hashes[l][i] = hash;
          hashCount[l][hash]++;
          hashIndex[l].require(hash, i.to!int);
        }
        
        foreach(hash; hashCount[l].keys) {
          hashTree.insert(HashValue(hashCount[l][hash], l, hashIndex[l][hash], hash));
        }
      }

      for(int turn; true; turn++) {
        bool added;
        bool[] used = new bool[](N);
        foreach(hv; hashTree.array) {
          auto i = hv.index;
          auto l = hv.length;
          if (signals.length + l > LA) continue;

          auto uniqueNodes = route[i..min($, i + l)].dup.sort.uniq;
          if (uniqueNodes.any!(n => used[n])) {
            if (l == 1) hashTree.removeKey(hv);
            continue;
          }

          foreach(n; uniqueNodes) used[n] = true;
          indiciesForSignalHash[l][hv.hash] = signals.length.to!int;
          signals ~= uniqueNodes.array;
          added = true;
          hashTree.removeKey(hv);
          insertedSignal ~= hv;
        }

        if (!added) break;
      }

      // hashTree.deb;
      signals ~= 0.repeat(LA).array;
      signals = signals[0..LA];

      indiciesForSignal[] = -1;
      foreach(i, s; signals.enumerate(0)) {
        if (indiciesForSignal[s] != -1) continue;

        indiciesForSignal[s] = i;
      }
    }

    void provisionSignal2() {
      bool[] covered = new bool[](route.length);
      int[] efficientSignals;

      while(efficientSignals.length < LA) {
        int[long][] hashCount = new int[long][](LB + 1);
        int[][long][] hashIndex = new int[][long][](LB + 1);

        foreach(i; 0..route.length.to!int) {
          if (covered[i]) continue;

          long hash = route[i].hashOf(seed);
          auto used = new int[](0).redBlackTree;

          int l = 1;
          foreach(x; i + 1..min(route.length.to!int, i + LB)) {
            if (covered[x]) break;
            l++;

            int r = route[x];
            if (r in used) continue;

            hash ^= r.hashOf(seed);
            hashCount[l][hash]++;
            hashIndex[l][hash] ~= i;
          }
        }
        
        HashValue best;
        foreach(l; 0..LB + 1) foreach(hash; hashCount[l].keys) {
          best = max(best, HashValue(hashCount[l][hash], l, hashIndex[l][hash][0], hash));
        }

        if (best.length > 0) {
          auto bestIndex = hashIndex[best.length][best.hash][0];
          efficientSignals ~= route[bestIndex..bestIndex + best.length];
          foreach(hi; hashIndex[best.length][best.hash]) foreach(i, node; route[hi..hi + best.length]) {
            covered[hi + i] = true;
          }
        } else {
          break;
        }
      }

      auto requiredNodesBase = route.redBlackTree;
      foreach(toRemove; 0..efficientSignals.length.to!int) {
        auto requiredNodes = requiredNodesBase.dup;
        foreach(node; efficientSignals[0..$ - toRemove]) {
          requiredNodes.removeKey(node);
        }

        auto requireNodesArray = requiredNodes.array;
        if (requireNodesArray.length + efficientSignals.length - toRemove <= LA) {
          signals = (requireNodesArray ~ efficientSignals ~ 0.repeat(LA).array)[0..LA];
          break;
        }
      }
    }

    struct Ans {
      Simulator sim;
      int score;
      string output;

      const int opCmp(const Ans other) {
        return cmp(
          [score, ],
          [other.score, ]
        );
      }
    }

    int[] signalUseCount;
    Ans simulate() {
      int score;
      string ans = format("%(%d %) \n", signals);

      int[][] accNodeCount = new int[][](N, LA + 1);
      foreach(i, r; signals) foreach(n; 0..N) {
        accNodeCount[n][i + 1] = accNodeCount[n][i] + (n == r ? 1 : 0);
      }

      int[][] startIndiciesPerSignal = new int[][](N, 0);
      foreach(si, n; signals.enumerate(0)) foreach(i; max(0, si - LB + 1)..min(LA - LB + 1, si + 1)) {
        startIndiciesPerSignal[n] ~= i;
      }

      signalUseCount = new int[](LA);

      int[] visitable = (-1).repeat(LB).array;
      int offsetB;
      foreach(ti, t; route.enumerate(0)) {
        if (!visitable.canFind(t)) {
          int sigSize = LB;
          int sigLeft;
          int best;

          foreach(sl; startIndiciesPerSignal[t]) {
            int satisfied;
            auto used = new int[](0).redBlackTree;
            for(int ri = ti; satisfied < LB && ri < route.length; ri++) {
              auto r = route[ri];
              if (r in used) continue;
              if (accNodeCount[r][sl + LB] - accNodeCount[r][sl] == 0) break;

              used.insert(r);
              satisfied++;
            }

            if (best.chmax(satisfied)) sigLeft = sl;
          }

          if (best == 0) assert("no satisfied signals");

          auto offset = offsetB % 2 == 0 ? 0 : LB - sigSize;
          ans ~= format("s %d %d %d \n", sigSize, sigLeft, offset);
          offsetB++;
          visitable[offset..offset + sigSize] = signals[sigLeft..sigLeft + sigSize].dup;
          score++;

          foreach(si; sigLeft..sigLeft + sigSize) signalUseCount[si]++;
        }

        ans ~= format("m %d \n", t);
      }
      return Ans(this, score, ans);
    }
  }

  int[][] graphNormal = new int[][](N, 0);
  foreach(uv; UV) {
    graphNormal[uv[0]] ~= uv[1];
    graphNormal[uv[1]] ~= uv[0];
  }

  int[][] graphMST = new int[][](N, 0); {
    long countValue(int[] uv) { return T.count(uv[0]) + T.count(uv[1]); }
    UnionFind uf = UnionFind(N);
    foreach(uv; UV.sort!((a, b) => countValue(a) > countValue(b))) {
      if (uf.same(uv[0], uv[1])) continue;

      uf.unite(uv[0], uv[1]);
      graphMST[uv[0]] ~= uv[1];
      graphMST[uv[1]] ~= uv[0];
    }
  }

  long[] costsNormal = 1L.repeat(N).array;
  long[][] allCosts = calcDistances(graphNormal, costsNormal);
  int[][] graphMST2 = new int[][](N, 0); {
    long bestDistSum = long.max;
    int center;
    foreach(n; 0..N) {
      if (bestDistSum.chmin(T.map!(t => allCosts[n][t]).sum)) {
        center = n;
      }
    }

    UnionFind uf = UnionFind(N);
    bool[] visited = new bool[](N);
    for(auto queue = DList!int(center); !queue.empty;) {
      auto cur = queue.front();
      queue.removeFront();
      if (visited[cur]) continue;
      visited[cur] = true;

      foreach(next; graphNormal[cur]) {
        if (visited[next]) continue;
        
        queue.insertBack(next);
        if (!uf.same(cur, next)) {
          uf.unite(cur, next);
          graphMST2[cur] ~= next;
          graphMST2[next] ~= cur;
        }
      }
    }
  }

  long[] costsWeighted = (10L ^^ 15).repeat(N).array; {
    // 訪問先から n 歩周囲のマスに対してコストを低減していく
    foreach(t; T) {
      bool[] visited = new bool[](N);
      auto queue = [t].redBlackTree;
      for(long x = 4; x <= 5; x++) {
        auto nodes = queue.array;
        queue.clear;
        foreach(node; nodes) {
          visited[node] = true;
          costsWeighted[node] = (costsWeighted[node] * (x - 1)) / x;
        
          foreach(next; graphNormal[node]) {
            if (visited[next]) continue;

            queue.insert(next);
          }
        }
      }
    }
  }


  auto bitArray = BitArray();
  foreach(i; 0..10^^5) bitArray ~= [false, true].choice;

  // auto sim = new Simulator("Normal Graph + Weighted Cost", graphNormal, costsWeighted);
  // foreach(t; 0..100) {
  //   sim.simulate();
  // }
  
  auto ans = [
    // new Simulator("Normal Graph + Plain Cost", graphNormal, costsNormal).simulate(),
    new Simulator("Normal Graph + Weighted Cost", graphNormal, costsWeighted).simulate(),
    new Simulator("MST Graph", graphMST, costsNormal).simulate(),
    new Simulator("MST Graph from Center", graphMST2, costsNormal).simulate(),
  ];

  auto best = ans.minElement;
  writeln(best.output);
  writefln("# %s", best.sim.name);
  best.score.deb;
  best.sim.signalUseCount.deb;
  // best.sim.insertedSignal.each!deb;
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
