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
    long[][] allCosts;

    int[] route;

    this(string name, int[][] g, long[] costs) {
      this.name = name;
      graph = g.map!"a.dup".array;
      nodeCosts = costs.dup;

      provisionRoute();
      provisionSignal();
      sortSignals();
      signals = (signals ~ 0.repeat(LA).array)[0..LA];
    }

    void provisionRoute() {
      int[][] nexts = new int[][](N, N);
      allCosts = new long[][](N, 0);

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
        allCosts[to] = costMemo;
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
    int[][] signalsArray;
    int[] aloneNodes;

    void provisionSignal() {
      const long resolution = LB;
      long[] sizes = iota(LB, 0, -1).map!(s => (s * resolution + resolution - 1) / resolution).array;

      BitArray initBA = BitArray(false.repeat(N).array);
      long[BitArray] scorePerHash;
      foreach(size; sizes) {
        foreach(i; iota(0, route.length.to!int - size, size)) {
          BitArray ba = initBA.dup;
          foreach(j; i..i + size) ba[route[j]] = true;
          scorePerHash[ba] += size^^9;
        }
      }

      int[] uniqueRoute; {
        bool[] used = new bool[](N);
        foreach(r; route) {
          if (!used[r]) {
            used[r] = true;
            uniqueRoute ~= r;
          }
        }
      }

      foreach(r; uniqueRoute) {
        BitArray ba = initBA.dup;
        ba[r] = true;
        if (!(ba in scorePerHash)) {
          scorePerHash[ba] = 1;
          aloneNodes ~= r;
        }
      }

      BitArray used = initBA.dup;
      int allowDuplicationSize = LA - uniqueRoute.length.to!int;
      foreach(kv; scorePerHash.byKeyValue.array.sort!"a.value > b.value") {
        BitArray duplicated = used & kv.key;
        if (duplicated.count > allowDuplicationSize) continue;
        if (kv.key.count - duplicated.count < kv.key.count / 3) continue;

        allowDuplicationSize -= duplicated.count;
        used |= kv.key;
        signalsArray ~= uniqueRoute.filter!(n => kv.key[n]).array;
      }
    }

    int[][] connectedSignals;
    void sortSignals() {
      BitArray initBA = BitArray(false.repeat(N).array);
      BitArray toBitArray(int[] sig) {
        BitArray ba = initBA.dup;
        foreach(s; sig) ba[s] = true;
        return ba;
      }

      signalsArray.sort!"a.length < b.length";
      auto rbt = signalsArray.length.to!int.iota.redBlackTree;
      while(!rbt.empty) {
        auto efficient = rbt.back;
        rbt.removeBack;

        int[] sides;
        foreach(small; rbt.array) {
          foreach(alone; signalsArray[small]) {
            if (graph[alone].any!(neighbor => signalsArray[efficient].canFind(neighbor))) {
              sides ~= small;
              rbt.removeKey(small);
              break;
            }
          }

          if (sides.length >= 2) break;
        }

        int[] connected;
        if (sides.length >= 1) connected ~= signalsArray[sides[0]];
        connected ~= signalsArray[efficient];
        if (sides.length >= 2) connected ~= signalsArray[sides[1]];

        signals ~= connected.dup;
        connectedSignals ~= connected;
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
      string ans = format("%(%d %) \n", signals);

      int[][] accNodeCount = new int[][](N, LA + 1);
      foreach(i, r; signals) foreach(n; 0..N) {
        accNodeCount[n][i + 1] = accNodeCount[n][i] + (n == r ? 1 : 0);
      }

      int[][] startIndiciesPerSignal = new int[][](N, 0);
      foreach(si, n; signals.enumerate(0)) foreach(i; max(0, si - LB + 1)..min(LA - LB + 1, si + 1)) {
        startIndiciesPerSignal[n] ~= i;
      }

      int[] visitable = (-1).repeat(LB).array;
      int score;
      int turn = 1;
      foreach(ti, t; route.enumerate(0)) {
        if (!visitable.canFind(t)) {
          int sigSize = LB;
          int sigLeft;
          int best;

          foreach(size; 1..LB + 1) foreach(sl; startIndiciesPerSignal[t]) {
            int satisfied;
            auto used = new int[](0).redBlackTree;
            for(int ri = ti; satisfied < size && ri < route.length; ri++) {
              auto r = route[ri];
              if (r in used) continue;
              if (accNodeCount[r][sl + size] - accNodeCount[r][sl] == 0) break;

              used.insert(r);
              satisfied++;
            }

            if (best < satisfied || (best == satisfied && sigSize > size)) {
              best = satisfied;
              sigLeft = sl;
              sigSize = size;
            }
          }

          int[int] uselessRange; {
            int pre = -100;
            int con;
            foreach(bi; 0..LB) {
              if (!route[ti..min($, ti + LB)].canFind(visitable[bi])) {
                if (pre == bi - 1) {
                  con++;
                  uselessRange[bi - con]++;
                } else {
                  uselessRange[bi] = 1;
                  con = 0;
                }
                pre = bi;
              }
            }
          }

          int partialSize, partialIndex; {
            foreach(kv; uselessRange.byKeyValue.array.sort!"a.value < b.value") {
              auto index = kv.key;
              auto size = kv.value;
              if (size >= sigSize) {
                partialIndex = index;
                partialSize = size;
                break;
              }
            }
          }

          // deb([turn, t], [best, sigSize, sigLeft], [partialSize, partialIndex]);

          if (sigSize <= partialSize) {
            // sigSize = min(partialSize, LA - partialIndex);
            ans ~= format("s %d %d %d \n", sigSize, sigLeft, partialIndex);
            visitable[partialIndex..partialIndex + sigSize] = signals[sigLeft..sigLeft + sigSize].dup;
          } else {
            sigSize = min(LB, LA - sigLeft);
            ans ~= format("s %d %d %d \n", sigSize, sigLeft, 0);
            visitable[0..0 + sigSize] = signals[sigLeft..sigLeft + sigSize].dup;
          }

          turn++;
          score++;
        }

        ans ~= format("m %d \n", t);
        turn++;
      }
      return Ans(this, score, ans);
    }

    Ans repeatSimulate(int tryCount) {
      Ans best;

      foreach(_; 0..tryCount) {
        signals = connectedSignals.randomShuffle(RND).joiner.array;
        auto ans = simulate();

        if (best.chmax(ans)) {}
      }
      return best;
    }
  }

  { // create ans
    int[][] graphNormal = new int[][](N, 0);
    foreach(uv; UV) {
      graphNormal[uv[0]] ~= uv[1];
      graphNormal[uv[1]] ~= uv[0];
    }

    long[] costsNormal = 1L.repeat(N).array;
    long[][] allCosts = calcDistances(graphNormal, costsNormal);
    int[][] graphMST2 = new int[][](N, 0); {
      long bestDistSum = long.max;
      int center;
      int[] centers;
      foreach(n; T) {
        if (bestDistSum.chmin(T.map!(t => allCosts[n][t]).sum)) {
          center = n;
        }
      }

      centers ~= center;
      UnionFind uf = UnionFind(N);
      bool[] visited = new bool[](N);
      for(auto queue = DList!int([center]); !queue.empty;) {
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

    int[][] graphMST3 = new int[][](N, 0); {
      long bestDistSum = long.max;
      int[] centers;
      foreach(c1; 0..N - 1) foreach(c2; c1 + 1..N) {
        if (bestDistSum.chmin(T.map!(t => min(allCosts[c1][t], allCosts[c2][t])).sum)) {
          centers = [c1, c2];
        }
      }

      UnionFind uf = UnionFind(N);
      bool[] visited = new bool[](N);
      for(auto queue = DList!int(centers); !queue.empty;) {
        auto cur = queue.front();
        queue.removeFront();
        if (visited[cur]) continue;
        visited[cur] = true;

        foreach(next; graphNormal[cur]) {
          if (visited[next]) continue;
          
          queue.insertBack(next);
          if (!uf.same(cur, next)) {
            uf.unite(cur, next);
            graphMST3[cur] ~= next;
            graphMST3[next] ~= cur;
          }
        }
      }
    }

    long[] costsWeighted2 = new long[](N); {
      foreach(t; T) {
        bool[] visited = new bool[](N);
        auto queue = [t].redBlackTree;
        for(long x = 4; x >= 1; x--) {
          auto nodes = queue.array;
          queue.clear;
          foreach(node; nodes) {
            visited[node] = true;
            costsWeighted2[node] += x ^^ 2;
          
            foreach(next; graphNormal[node]) {
              if (visited[next]) continue;

              queue.insert(next);
            }
          }
        }
      }
      auto maxi = costsWeighted2.maxElement;
      foreach(i; 0..N) costsWeighted2[i] = maxi - costsWeighted2[i];
    }

    auto ans = [
      // new Simulator("Normal Graph + Plain Cost", graphNormal, costsNormal).simulate(),
      new Simulator("Normal Graph + Weighted Cost", graphNormal, costsWeighted2).simulate(),
      new Simulator("Normal Graph + Exponential Weighted Cost", graphNormal, costsWeighted).simulate(),
      new Simulator("MST Graph from Center", graphMST2, costsNormal).simulate(),
      new Simulator("MST Graph from Two Centers", graphMST3, costsNormal).simulate(),
    ];

    auto best = ans.minElement;
    int tryCount;
    while(!elapsed(2500)) {
      best.chmin(best.sim.repeatSimulate(1));
      tryCount++;
    }

    tryCount.deb;
    writeln(best.output);
    debug {
      best.score.deb;
      best.sim.signalsArray.each!deb;
      // best.sim.aloneNodes.length.deb;
    }
    writefln("# %s", best.sim.route.length);
    writefln("# %s", best.sim.name);
  }
}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("# "); writeln(t); }}
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
