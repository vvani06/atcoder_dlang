void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  struct Coord {
    int x, y;

    int dist(Coord other) {
      return (x - other.x)^^2 + (y - other.y)^^2;
    }
  }

  bool intersect(ref Coord p1, ref Coord p2, ref Coord q1, ref Coord q2) {
    if (p1 == q1 || p1 == q2 || p2 == q1 || p2 == q2) return false;
    if (max(p1.x, p2.x) < min(q1.x, q2.x) ||
        max(q1.x, q2.x) < min(p1.x, p2.x) ||
        max(p1.y, p2.y) < min(q1.y, q2.y) ||
        max(q1.y, q2.y) < min(p1.y, p2.y))
        return false;

    int sign(int v) {
      return v > 0 ? 1 : v < 0 ? -1 : 0;
    }

    int orientation(ref Coord a, ref Coord b, ref Coord c) {
      return sign((b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x));
    }

    auto o1 = orientation(p1, p2, q1);
    auto o2 = orientation(p1, p2, q2);
    auto o3 = orientation(q1, q2, p1);
    auto o4 = orientation(q1, q2, p2);
    return (o1 * o2 <= 0) && (o3 * o4 <= 0);
  }

  int N = scan!int;
  int M = scan!int;
  int K = scan!int;
  int[][] D = scan!int(2 * N).chunks(2).array;
  int[][] S = scan!int(2 * M).chunks(2).array;
  real[][] P = scan!real(K * N).chunks(N).array;
  P = P.dup ~ P.map!(p => p.map!(x => 1.0 - x).array).array;
  auto PN = P.length.to!int;

  struct Ans {
    int startNode;
    int[] assigns;
    int[][] graph;

    this(int startNode, int[] assigns, int[][] edges) {
      this.startNode = startNode;
      this.assigns = assigns;
      fixUnassigned();

      graph = new int[][](N + M, 0);
      foreach(e; edges[1..$]) graph[e[0]] ~= e[1];
      foreach(e; edges[1..$]) graph[e[0]] ~= e[1];
    }

    void fixUnassigned() {
      auto restGoals = iota(N).redBlackTree;
      foreach(a; assigns[0..N]) restGoals.removeKey(a);
      foreach(i; 0..N) {
        if (assigns[i] != -1) continue;

        assigns[i] = restGoals.front;
        restGoals.removeFront();
      }
    }

    real[] scores() {
      if (assigns.empty) return [];

      auto sorted = topologicalSort(graph);
      real[] rets;

      foreach(item; 0..N) {
        real[] p = new real[](N + M);
        p[] = 0;
        p[startNode] = 1;
        foreach(cur; sorted) {
          if (cur < N) continue;
          if (graph[cur].empty) {
            if (p[cur] == 0) continue; else return [];
          }

          auto v1 = graph[cur][0];
          auto v2 = graph[cur][1];
          p[v1] += p[cur] * P[assigns[cur]][item];
          p[v2] += p[cur] * (1.0 - P[assigns[cur]][item]);
        }
        rets ~= p[assigns[0..N].countUntil(item)];
      }

      return rets;
    }

    real score() {
      auto rets = scores();
      return rets.empty ? -1 : rets.sum; 
    }

    long scoreForHuman() {
      return ((N.to!real - score()) * 10^^9 / N).to!long;
    }

    void outputAsAns() {
      if (score >= -1) {
        writefln("%(%s %)", assigns[0..N]);
        writefln("%(%s %)", [startNode]);

        foreach(_; 0..N - 3) writeln();
        foreach(k, sw; zip(assigns[N..$], graph[N..$])) {
          if (sw.empty) {
            writeln("-1");
          } else {
            writefln("%s %(%s %)", k % K, k < K ? sw[0..2] : sw[0..2].retro.array);
          }
        }
      } else {
        writefln("%(%s %)", iota(N));
        writefln("%(%s %)", [0]);
        writefln("%(%s %)", (-1).repeat(M));
      }
    }
  }

  Coord[] coords = D.map!(c => Coord(c[0], c[1])).array ~ S.map!(c => Coord(c[0], c[1])).array ~ Coord(0, 5000);

  struct Node {
    int id;

    long x() { return coords[id].x; }
    long y() { return coords[id].y; }
    long sum() { return coords[id].x + coords[id].y; }
    long dist(Coord other) { return (x - other.x)^^2 + (y - other.y)^^2; }
    long dist(Node other) { return (x - other.x)^^2 + (y - other.y)^^2; }
    long distX(Node other) { return (x - other.x)^^2 * 100 + (y - other.y)^^2; }
    real theta(Node other) { return atan2(other.y.to!real - y, other.x.to!real - x); }

    string toString() {
      return "# Node: % 4s (% 5d, % 5d)".format(id, x, y);
    }
  }

  struct Edge {
    int a, b;

    bool cross(Edge other) {
      return intersect(coords[a], coords[b], coords[other.a], coords[other.b]);
    }

    int from() { return a; }
    int to() { return b; }
  }

  int[][] sortersFor = iota(N).map!(item => iota(PN).array.sort!((a, b) => P[a][item] > P[b][item]).array).array;
  int[][] swappables = sortersFor.map!(a => a[0..K / 2]).array;
  int[] swapIndex = iota(PN).map!(p => P[p].maxIndex.to!int).array;

  Node[] allNodes = iota(N + M + 1).map!(i => Node(i)).array;
  Node[] goalNodes = allNodes[0..N];
  Node[] sortNodes = allNodes[N..$ - 1];

  struct CompositeSorter {
    int[] sorters;
    int ignored;
    real[] ratios;

    this(int[] sorters, int ignored = 0) {
      this.sorters = sorters.dup;
      this.ignored = ignored;
      ratios = iota(N).map!(i => (2^^i & ignored) != 0 ? 0.0L : 1.0L).array;
      foreach(p; sorters.map!(s => P[s])) {
        foreach(i; 0..N) ratios[i] *= p[i];
      }
    }

    CompositeSorter add(int sorter) {
      return CompositeSorter(sorters ~ sorter, ignored);
    }

    real scoreFor(int item) {
      return ratios[item] + (1.0L - (ratios[0..item] ~ ratios[item + 1..$]).maxElement)*9;
    }
  }

  final class SorterServer {
    CompositeSorter[][] sorters;
    int[] orderd;

    this(int depthLimit, int rankLimit) {
      sorters = new CompositeSorter[][](N, 0);

      auto rbt = iota(N).redBlackTree;
      int ignored;
      while(!rbt.empty) {
        CompositeSorter[] best = [CompositeSorter([], ignored)];
        int bestItem;
        real bestScore = 0;
        foreach(item; rbt) {
          auto cur = composeSorterFor(item, depthLimit, rankLimit, ignored);
          if (bestScore.chmax(cur[depthLimit - 1].scoreFor(item))) {
            bestItem = item;
            best = cur;
          }
        }

        sorters[bestItem] = best;
        rbt.removeKey(bestItem);
        ignored += 2^^bestItem;
        orderd ~= bestItem;
      }
    }

    int[] orderedItemIds(int depth) {
      return orderd;
      // return N.iota.array.sort!((a, b) => sorters[a][depth].scoreFor(a) > sorters[b][depth].scoreFor(b)).array;
    }

    int serve(int item, int depth, int index) {
      return sorters[item][depth].sorters[index];
    }

    private CompositeSorter[] composeSorterFor(int item, int depthLimit, int rankLimit, int ignored) {
      auto sorters = sortersFor[item][0..rankLimit];

      auto base = CompositeSorter([], ignored);
      auto ret = base.repeat(depthLimit + 1).array;
      real[] bestScore = 0.0L.repeat(depthLimit + 1).array;

      void dfs(int depth, int rank, CompositeSorter cs) {
        if (bestScore[depth].chmax(cs.scoreFor(item))) ret[depth] = cs;
        if (depth == depthLimit) return;

        foreach(next; rank..rankLimit) {
          dfs(depth + 1, next, cs.add(sorters[next]));
        }
      }
      dfs(0, 0, base);
      return ret;
    }
  }

  auto sorterServer = new SorterServer(8, 5);

  Ans calcIdealGraph(int branchesPerGoal, int depth, bool enableHeuristics) { // 理論値計算
    int[][] edges;
    int[] assigns = (-1).repeat(N).array ~ 0.repeat(M).array;
    int startNode = N;

    foreach(goal; 0..N - 1) {
      foreach(branchId; 0..branchesPerGoal) {
        auto offset = startNode + (goal * branchesPerGoal + branchId) * depth;
        
        int[][] tree;
        foreach(d; 0..depth) {
          tree ~= [offset + d, d < depth - 1 ? offset + d + 1 : goal];
          tree ~= [offset + d, offset + depth];

          auto item = sorterServer.orderedItemIds(depth)[goal];
          assigns[offset + d] = sorterServer.serve(item, depth, d);
        }

        edges ~= tree;
      }
    }

    auto finalNode = startNode + (N - 1) * branchesPerGoal * depth;
    edges ~= [[finalNode, N - 1], [finalNode, N - 1]];
    assigns[0..N] = sorterServer.orderedItemIds(depth);

    auto ans = Ans(startNode, assigns, edges);
    if (!enableHeuristics)  return ans;

    auto bestAns = ans;
    bestAns.scoreForHuman().deb;
    bestAns.scores().deb;
    real bestScore = bestAns.score;

    auto sorterIndicies = iota(N, N + M).filter!(s => !bestAns.graph[s].empty).array;
    while(!elapsed(1900)) {
      auto target = sorterIndicies.choice(RND);
      auto origin = bestAns.assigns[target];

      auto best = origin;
      foreach(swapTo; swappables[swapIndex[origin]]) {
        bestAns.assigns[target] = swapTo;
        
        if (bestScore.chmax(bestAns.score())) {
          best = swapTo;
        }
      }
      bestAns.assigns[target] = best;
    }
    return bestAns;
  }

  version (IDEAL) {
    Ans ideal;
    foreach(depth; 3..8) {
      auto cur = calcIdealGraph(min(6, (M / (N - 1)) / depth), depth, false);
      if (ideal.score < cur.score) {
        ideal = cur;
      }
    }

    real bestScore = ideal.score;
    auto sorterIndicies = iota(N, N + M).filter!(s => !ideal.graph[s].empty).array;
    while(!elapsed(1900)) {
      auto target = sorterIndicies.choice(RND);
      auto origin = ideal.assigns[target];

      auto best = origin;
      foreach(swapTo; swappables[swapIndex[origin]]) {
        ideal.assigns[target] = swapTo;
        
        if (bestScore.chmax(ideal.score())) {
          best = swapTo;
        }
      }
      ideal.assigns[target] = best;
    }
    stderr.writeln(ideal.scoreForHuman());
    ideal.outputAsAns();
    return;
  }

  {
    auto depth = 5;
    auto branches = min(2, (M - 1) / (N - 1) / depth);
    auto server = new SorterServer(depth, 5);

    int[] used = new int[](N + M);
    auto nearests(Node from) {
      return sortNodes.sort!((a, b) => from.dist(a) < from.dist(b)).filter!(n => used[n.id] == 0).array;
    }
    Node nearestFirst(Node from) {
      foreach(to; sortNodes.sort!((a, b) => from.dist(a) < from.dist(b))) {
        if (used[to.id] != 0) continue;

        return to;
      }
      assert(0, "No canditate node");
    }
    
    Node startNode = nearestFirst(Node(N + M));
    used[startNode.id] = 1;
    Node baseNode = startNode;
    Edge[] edges = [Edge(N + M, startNode.id)];
    bool crossed(Edge e, Edge[] es = []) { return es.empty ? edges.retro.any!(x => e.cross(x)) : es.any!(x => e.cross(x)); }

    Node[][] sideTrees;
    int[] sideGoals;
    foreach(goal; goalNodes.sort!"a.x < b.x"[0..$ - 1].map!(a => a.repeat(branches)).joiner) {
      foreach(next; nearests(goal)[0..$ / 2]) {
        auto theta = goal.theta(next);

        Node[] tree = [next];
        Edge[] newEdges = [Edge(next.id, goal.id)];
        if (crossed(newEdges[0])) continue;

        foreach(leaf; nearests(goal)) {
          if (leaf == next) continue;
          if (abs(theta - goal.theta(leaf)) > 0.5) continue;

          auto edge = Edge(leaf.id, tree.back.id);
          if (crossed(edge)) continue;
          if (crossed(edge, newEdges)) continue;

          tree ~= leaf;
          newEdges ~= edge;
          if (tree.length >= depth) break;
        }

        if (tree.length == depth) {
          auto baseEdge = Edge(baseNode.id, tree.back.id);
          if (crossed(baseEdge) || crossed(baseEdge, newEdges)) continue;
          newEdges ~= baseEdge;
          
          Node sideNode = Node(-1);
          foreach(side; nearests(tree[$ - 1])) {
            if (tree.canFind(side)) continue;
            // if (abs(theta - goal.theta(side)) <= 0.20) continue;

            auto sideEdges = tree.map!(t => Edge(t.id, side.id)).array;
            if (sideEdges.any!(s => crossed(s) || crossed(s, newEdges))) continue;

            sideNode = side;
            break;
          }
          if (sideNode.id != -1) {
            edges ~= newEdges;
            edges ~= tree.map!(t => Edge(t.id, sideNode.id)).array;
            foreach(node; tree ~ sideNode) used[node.id] = true;
            sideTrees ~= tree;
            sideGoals ~= goal.id;
            deb(goal, tree, [sideNode]);
            used[goal.id]++;
            baseNode = sideNode;
            break;
          }
        }
      }
    }

    foreach(goal; goalNodes.sort!((a, b) => used[a.id] < used[b.id])) {
      auto edge = Edge(baseNode.id, goal.id);
      if (crossed(edge)) continue;

      edges ~= edge;
      break;
    }

    int[] assigns = new int[](N + M);
    assigns[0..N] = -1;
    int preGoal = sideGoals[0];
    int goalIndex;
    sideGoals.uniq.deb;
    foreach(goal, tree; zip(sideGoals, sideTrees)) {
      if (goal != preGoal) goalIndex++;

      auto item = server.orderedItemIds(depth)[goalIndex];
      assigns[goal] = item;
      foreach(d; 0..depth) {
        assigns[tree[d].id] = server.serve(item, depth, d);
      }
      preGoal = goal;
    }

    auto ans = Ans(startNode.id, assigns, edges.map!"[a.a, a.b]".array);
    ans.outputAsAns();
    return;
  }

  class Sim {
    this(Coord[] coords) {
    }

    Ans generate(int bottomBorder, int stepWidth, int sideTreeWidth, int sideTreeHeight) {
      bool[] used = new bool[](N + M);
      used[0..N] = true;
      Edge[] edges;
      bool hasIntersect(Edge ne) { return edges.retro.any!(e => ne.cross(e)); }
      int[] sortees = sorterServer.orderedItemIds(sideTreeHeight);
      int[] goalsCount = 1.repeat(N).array;

      int connectToNearestGoal(Node node, int limitY = 0) {
        foreach(goal; goalNodes.dup.sort!((a, b) => node.distX(a)*goalsCount[a.id] < node.distX(b)*goalsCount[b.id])) {
          if (goal.y < limitY) continue;
          
          auto newEdge = Edge(node.id, goal.id);
          if (hasIntersect(newEdge)) continue;

          edges ~= newEdge;
          return goal.id;
        }

        foreach(via; sortNodes) {
          if (used[via.id]) continue;
          
          auto viaEdge = Edge(node.id, via.id);
          if (hasIntersect(viaEdge)) continue;

          foreach(goal; goalNodes) {
            auto goalEdge = Edge(via.id, goal.id);
            if (hasIntersect(goalEdge)) continue;

            edges ~= [viaEdge, goalEdge];
            return goal.id;
          }
        }
        return -1;
      }

      Node startNode = sortNodes.minElement!"a.sum";
      used[startNode.id] = true;
      Node[] baseNodes = [startNode];
      edges ~= Edge(startNode.id, N + M);

      int[] assigns = (-1).repeat(N).array ~ 0.repeat(M).array;
      int[] groupGoals;
      int[][] groupNodes;

      {
        Node preNode = startNode;
        foreach(node; sortNodes.filter!(n => n.y <= bottomBorder).array.sort!"a.x < b.x") {
          if (used[node.id] || node.x < preNode.x || node.x - preNode.x < stepWidth) continue;

          auto baseEdge = Edge(preNode.id, node.id);
          if (hasIntersect(baseEdge)) continue;

          used[node.id] = true;
          edges ~= baseEdge;
          auto preSide = preNode;
          int height;
          int[] sideNodes = [preSide.id];
          foreach(side; sortNodes.filter!(n => preNode.y < n.y && abs(preNode.x - n.x) < sideTreeWidth).array.sort!"a.y < b.y") {
            if (height >= sideTreeHeight) break;
            if (side.y <= bottomBorder || used[side.id]) continue;

            auto newEdges = [Edge(preSide.id, side.id), Edge(side.id, node.id)];
            if (newEdges.any!hasIntersect) continue;
            
            edges ~= newEdges;
            sideNodes ~= side.id;
            preSide = side;
            used[side.id] = true;
            height++;
          }
          
          auto goal = connectToNearestGoal(preSide, preNode.y.to!int);
          if (goal == -1) return Ans();

          groupNodes ~= sideNodes;
          groupGoals ~= goal;
          preNode = node;
          baseNodes ~= node;
        }
        
        if (connectToNearestGoal(preNode) == -1) return Ans();

        auto bases = baseNodes.map!"a.id".redBlackTree;

        Edge[] sortedEdges;
        sortedEdges ~= edges.filter!(e => !(e.to in bases)).array;
        sortedEdges ~= edges.filter!(e => (e.to in bases)).array;
        edges = sortedEdges;

        int goalCount;
        int[] goalItem = (-1).repeat(N).array;
        foreach(goal, sideNodes; zip(groupGoals, groupNodes)) {
          auto item = goalItem[goal] == -1 ? sortees[goalCount] : goalItem[goal];
          foreach(i, node; sideNodes) {
            assigns[node] = sorterServer.serve(item, sideNodes.length.to!int, i.to!int);
          }

          if (goalItem[goal] == -1) {
            assigns[goal] = sortees[goalCount++];
            goalItem[goal] = item;
          }
        }
      }

      return Ans(startNode.id, assigns, edges.map!"[a.a, a.b]".array);
    }
  }

  {
    auto sim = new Sim(D.map!(c => Coord(c[0], c[1])).array ~ S.map!(c => Coord(c[0], c[1])).array ~ Coord(0, 5000));
    real bestScore = long.min;
    Ans bestAns;
    foreach(bottomBorder, stepWidth, sideTreeHeight; cartesianProduct(iota(200, 2001, 200), iota(50, 1001, 50), iota(2, 8, 1))) {
      if (elapsed(1400)) break;

      foreach(sideTreeWidth; [stepWidth, stepWidth*3/2, stepWidth/2]) {
        auto ans = sim.generate(bottomBorder, stepWidth, sideTreeWidth, sideTreeHeight);
        if (bestScore.chmax(ans.score())) {
          bestAns = ans;
        }
      }
    }
    coords = coords.map!(c => Coord(c.x, 10000 - c.y)).array;
    foreach(bottomBorder, stepWidth, sideTreeHeight; cartesianProduct(iota(200, 2001, 200), iota(50, 1001, 50), iota(2, 8, 1))) {
      if (elapsed(1400)) break;

      foreach(sideTreeWidth; [stepWidth, stepWidth*3/2, stepWidth/2]) {
        auto ans = sim.generate(bottomBorder, stepWidth, sideTreeWidth, sideTreeHeight);
        if (bestScore.chmax(ans.score())) {
          bestAns = ans;
        }
      }
    }

    auto sorterIndicies = iota(N, N + M).filter!(s => !bestAns.graph[s].empty).array;
    sorterIndicies.deb;

    auto baseAns = bestAns;
    bestAns.scoreForHuman().deb;
    while(!elapsed(1900)) {
      auto target = sorterIndicies.choice(RND);
      auto origin = bestAns.assigns[target];

      auto best = origin;
      foreach(swapTo; swappables[swapIndex[origin]]) {
        bestAns.assigns[target] = swapTo;
        
        if (bestScore.chmax(bestAns.score())) {
          best = swapTo;
        }
      }
      bestAns.assigns[target] = best;
    }

    bestAns.scoreForHuman().deb;
    bestAns.outputAsAns();
  }
}

// ----------------------------------------------

import std;
import core.bitop;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(lazy T t){ debug { write("# "); writeln(t); }}
void debf(T ...)(lazy T t){ debug { write("# "); writefln(t); }}
// void deb(T ...)(T t){ debug {  }}
T[] divisors(T)(T n) { T[] ret; for (T i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == float) || is(T == double) || is(T == float)) "%.16f".writefln(fn());
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

int[] topologicalSort(int[][] g) {
  auto size = g.length.to!int;
  auto depth = new int[](size);
  foreach(e; g) foreach(p; e) depth[p]++;

  auto q = heapify!"a > b"(new int[](0));
  foreach(i; 0..size) if (depth[i] == 0) q.insert(i);

  int[] sorted;
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

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}
