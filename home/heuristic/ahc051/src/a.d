void main() { runSolver(); }

// ---------------------------------------------

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

version = CIRCLE;

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;
  int N = scan!int;
  int M = scan!int;
  int K = scan!int;
  int[][] D = scan!int(2 * N).chunks(2).array;
  int[][] S = scan!int(2 * M).chunks(2).array;
  real[][] P = scan!real(K * N).chunks(N).array;
  P = P.dup ~ P.map!(p => p.map!(x => 1.0 - x).array).array;
  auto PN = P.length.to!int;

  int[][] sortersFor = iota(N).map!(item => iota(PN).array.sort!((a, b) => P[a][item] > P[b][item]).array).array;
  int[][] swappables = sortersFor.map!(a => a).array;
  int[] swapIndex = iota(PN).map!(p => P[p].maxIndex.to!int).array;

  Coord[] coords = D.map!(c => Coord(c[0], c[1])).array ~ S.map!(c => Coord(c[0], c[1])).array ~ Coord(0, 5000);

  struct Ans {
    int startNode;
    int[] assigns;
    int[][] graph;

    this(int startNode, int[] assigns, int[][] edges) {
      this.startNode = startNode;
      this.assigns = assigns;
      fixUnassigned();

      graph = new int[][](N + M, 0);
      auto realEdges = edges.filter!(e => e.maxElement < N + M).array;
      foreach(e; realEdges) graph[e[0]] ~= e[1];
      foreach(e; realEdges) if (graph[e[0]].length < 2) graph[e[0]] ~= e[1];
      // graph.enumerate(0).each!deb;
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
      // sorted.deb;
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
        // deb([item], assigns[0..N].countUntil(item), p[0..N]);
      }

      return rets;
    }

    void randomImprove() {
      auto sorterIndicies = iota(N, N + M).filter!(s => graph[s].uniq.walkLength == 2).array;
      auto bestScore = score();
      while(!elapsed(1900)) {
        auto target = sorterIndicies.choice(RND);
        auto origin = assigns[target];

        auto best = origin;
        foreach(swapTo; swappables[swapIndex[origin]]) {
          assigns[target] = swapTo;
          
          if (bestScore.chmax(score())) {
            best = swapTo;
          }
        }
        assigns[target] = best;
      }
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

  struct Node {
    int id;

    bool goal() { return id < N; }
    bool sorter() { return id >= N && id < N + M; }
    long x() { return coords[id].x; }
    long y() { return coords[id].y; }
    long sum() { return coords[id].x + coords[id].y; }
    long dist(Coord other) { return (x - other.x)^^2 + (y - other.y)^^2; }
    long dist(Node other) { return (x - other.x)^^2 + (y - other.y)^^2; }
    long distX(Node other) { return (x - other.x)^^2 * 100 + (y - other.y)^^2; }
    long distX3(Node other) { return (x - other.x)^^2 * 3 + (y - other.y)^^2; }
    real theta(Node other) { return atan2(other.y.to!real - y, other.x.to!real - x); }

    string toString() {
      return "# Node: % 4s (% 5d, % 5d)".format(id, x, y);
    }
  }

  struct NaiveEdge {
    Coord a, b;
    int minY, maxY;

    this(Coord a, Coord b) {
      this.a = a;
      this.b = b;
      minY = min(a.y, b.y);
      maxY = max(a.y, b.y);
    }

    bool intersect(NaiveEdge other) {
      return .intersect(a, b, other.a, other.b);
    }
  }

  struct Edge {
    int a, b;

    bool cross(Edge other) {
      return intersect(coords[a], coords[b], coords[other.a], coords[other.b]);
    }

    int from() { return a; }
    int to() { return b; }
    long dist() { return coords[a].dist(coords[b]); }
    long distNode(Node n) { return min(n.dist(coords[a]), n.dist(coords[b])); }

    int minY() { return min(coords[a].y, coords[b].y); }
    int maxY() { return max(coords[a].y, coords[b].y); }

    NaiveEdge naive() {
      return NaiveEdge(coords[a], coords[b]);
    }
  }

  class Edges {
    Edge[] edges;
    RedBlackTree!(NaiveEdge, "a.minY > b.minY", true) minTree;
    RedBlackTree!(NaiveEdge, "a.maxY < b.maxY", true) maxTree;

    this() {
      minTree = new typeof(minTree)(new NaiveEdge[](0));
      maxTree = new typeof(maxTree)(new NaiveEdge[](0));
    }

    void insert(Edge e) {
      edges ~= e;
      minTree.insert(e.naive);
      maxTree.insert(e.naive);
    }

    void insert(Edge[] es) {
      foreach(e; es) insert(e);
    }

    auto intersectCandidates(Edge e) {
      if (e.maxY < 5000) {
        return minTree.upperBound(NaiveEdge(Coord(0, e.maxY + 1), Coord(0, e.maxY + 1)));
      } else {
        return maxTree.upperBound(NaiveEdge(Coord(0, e.minY - 1), Coord(0, e.minY - 1)));
      }
    }

    bool intersect(Edge e) {
      auto ne = e.naive;
      deb(e.naive, [edges.length, intersectCandidates(e).walkLength]);
      foreach(edge; intersectCandidates(e)) {
        if (ne.intersect(edge)) return true;
      }
      return false;
    }

    int[][] asArray() {
      return edges.map!"[a.a, a.b]".array;
    }
  }

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

  auto sorterServer = new SorterServer(6, 8);
  Node[] allNodes = iota(N + M + 1).map!(i => Node(i)).array;
  Node[] goalNodes = allNodes[0..N];
  Node[] sortNodes = allNodes[N..$ - 1].dup.randomShuffle(RND).array[0..min(500, $)];

  Node[][] cachedSortNodes = new Node[][](N + M);
  Node[] sortNodesNearby(Node node) {
    if (!cachedSortNodes[node.id].empty) return cachedSortNodes[node.id];

    return cachedSortNodes[node.id] = sortNodes.dup.sort!((a, b) => node.dist(a) < node.dist(b)).array;
  }

  (MonoTime.currTime() - StartTime).total!"msecs".deb;

  version (IDEAL) {
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
      bestAns.randomImprove();
      return bestAns;
    }

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

  version (CIRCLE) {
    Ans createGraph(Coord delegate(real) coordinator, int depth, int branches) {
      // auto branches = min(4, (M - 1) / (N - 1) / depth);
      auto baseNodeCount = branches * N;

      Node[] baseNodes;
      Edges tEdges = new Edges();
      // bool crossed(Edge e, Edge[] extra = []) { return false; }
      bool crossed(Edge e, Edge[] extra = []) { return extra.any!(x => e.cross(x)) || tEdges.intersect(e); }

      Node preNode = Node(N + M);
      int[] used = new int[](N + M);
      foreach(index; 0..baseNodeCount) {
        real coordinateRatio = (index + 1).to!real / baseNodeCount;
        auto candidate = coordinator(coordinateRatio);
        auto nodes = (index == baseNodeCount - 1 ? goalNodes : sortNodes).dup;
        auto sorted = nodes.sort!((a, b) => a.dist(candidate) < b.dist(candidate));
        foreach(s; sorted) {
          if (used[s.id]) continue;

          auto edge = Edge(preNode.id, s.id);
          if (crossed(edge)) continue;

          baseNodes ~= s;
          used[s.id] = true;
          tEdges.insert(Edge(preNode.id, s.id));
          preNode = s;
          break;
        }
      }

      used[baseNodes[$ - 1].id] = branches;

      Node[][] sideNodes = baseNodes.map!(bn => [bn]).array;
      int[] sideGoals = sideNodes.map!(bn => -1).array;
      foreach(i, base; baseNodes[0..$ - 1].enumerate(0)) {
        // edges.sort!((u, v) => u.distNode(base) < v.distNode(base));
        auto goals = goalNodes.dup.sort!((a, b) => a.dist(base) < b.dist(base));
        auto goalsUseSorted = iota(branches).map!(br => goals.filter!(g => used[g.id] == br)).joiner;

        GOAL: foreach(goal; goalsUseSorted) {
          auto theta = base.theta(goal);
          auto nextBaseIndex = i + 1;
          auto nextBaseNode = baseNodes[nextBaseIndex];

          Node[] tree;
          Edge[] newEdges;
          foreach(side; sortNodesNearby(base)) {
            if (used[side.id] || abs(theta - base.theta(side) > 5)) continue;

            Edge[] sideEdges;
            sideEdges ~= Edge((tree.empty ? base : tree.back).id, side.id);
            sideEdges ~= Edge(side.id, nextBaseNode.id);
            if (tree.length == depth - 2) sideEdges ~= Edge(side.id, goal.id);

            if (sideEdges.any!(e => crossed(e, newEdges))) continue;

            tree ~= side;
            newEdges ~= sideEdges;

            if (tree.length == depth - 1) {
              // tree.deb;
              tEdges.insert(newEdges);
              sideNodes[i] ~= tree;
              sideGoals[i] = goal.id;
              foreach(node; tree ~ goal) used[node.id]++;
              break GOAL;
            }
          }

          if (tree.length >= 2) {
            auto goalEdge = Edge(tree.back.id, goal.id);
            if (crossed(goalEdge, newEdges)) continue;

            tEdges.insert(newEdges ~ goalEdge);
            sideNodes[i] ~= tree;
            sideGoals[i] = goal.id;
            foreach(node; tree ~ goal) used[node.id]++;
            break GOAL;
          }
        }
      }
      
      // sideNodes.each!deb;
      auto startNode = baseNodes[0].id;
      auto assigns = (-1).repeat(N).array ~ 0.repeat(M).array; {
        int[int] itemPerGoal;
        int itemIndex;
        foreach(i, sides; sideNodes.enumerate(0)) {
          auto goal = sideGoals[i];
          if (goal == -1) continue;

          auto item = itemPerGoal.get(goal, sorterServer.orderedItemIds(depth)[itemIndex++]);
          itemPerGoal[goal] = item;
          assigns[goal] = item;
          foreach(d; 0..sides.length.to!int) {
            assigns[sides[d].id] = sorterServer.serve(item, sides.length.to!int, d);
          }
        }
      }
      auto ans = Ans(startNode, assigns, tEdges.asArray().retro().array());

      // assigns[0..N].deb;
      // assigns[N..$].deb;
      // edgesArray.each!deb;
      // ans.randomImprove();
      // ans.outputAsAns();

      return ans;
    }

    class Coordinator {
      static auto circle(real radius) {
        return (real ratio) {
          auto theta = 2.0 * PI * ratio;
          return Coord(
            5000 + (-5000.0 * cos(theta)).to!int,
            5000 + (radius * sin(theta)).to!int,
          );
        };
      }

      static auto linear(Coord from, Coord to) {
        return (real ratio) {
          real rev = 1.0 - ratio;
          return Coord(
            (rev * from.x + ratio * to.x).to!int,
            (rev * from.y + ratio * to.y).to!int,
          );
        };
      }

      static auto linear3(Coord a, Coord b, Coord c, Coord d) {
        return (real ratio) {
          ratio *= 2.99;
          auto seg = [a, b, c, d][ratio.to!int..ratio.to!int + 2];
          ratio %= 1;
          real rev = 1.0 - ratio;
          return Coord(
            (rev * seg[0].x + ratio * seg[1].x).to!int,
            (rev * seg[0].y + ratio * seg[1].y).to!int,
          );
        };
      }
    }

    auto coordinators = [
      Coordinator.circle(4000),
      Coordinator.circle(4500),
      Coordinator.circle(3500),
      Coordinator.circle(5000),
      Coordinator.circle(3000),
      Coordinator.linear(Coord(0, 0), Coord(10000, 10000)),
      Coordinator.linear3(Coord(0, 10000), Coord(10000, 10000), Coord(10000, 0), Coord(0, 0)),
    ];

    Ans ans;
    real bestScore = -1;
    foreach(inverted; 0..2) {
      coords = coords.map!(c => Coord(c.x, 10000 - c.y)).array;

      foreach(depth; [4])
      foreach(branches; [min(4, (M - 1)/(N - 1)/depth)])
      foreach(coordinator; coordinators) {
        if (elapsed(1500)) break;

        auto t = createGraph(coordinator, depth, branches);
        if (bestScore.chmax(t.score())) {
          ans = t;
        }
        deb([t.score()], [inverted, depth, branches], coordinator);
        (MonoTime.currTime() - StartTime).total!"msecs".deb;
      }
    }

    ans.randomImprove();
    ans.scoreForHuman().deb;
    ans.outputAsAns();
    return;
  }

  version (BOTTOM) {
    class Sim {
      this(Coord[] coords) {}
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
    { // 左から右に流れるベースラインの実装
      auto sim = new Sim(D.map!(c => Coord(c[0], c[1])).array ~ S.map!(c => Coord(c[0], c[1])).array ~ Coord(0, 5000));
      real bestScore = long.min;
      Ans bestAns;
      foreach(inv; 0..2) {
        if (inv == 1) coords = coords.map!(c => Coord(c.x, 10_000 - c.y)).array;

        foreach(bottomBorder, stepWidth, sideTreeHeight; cartesianProduct(iota(200, 2001, 100), iota(50, 1001, 50), iota(2, 8, 1))) {
          if (elapsed(1400)) break;

          foreach(sideTreeWidth; [stepWidth, stepWidth*3/2, stepWidth/2]) {
            auto ans = sim.generate(bottomBorder, stepWidth, sideTreeWidth, sideTreeHeight);
            if (bestScore.chmax(ans.score())) {
              bestAns = ans;
            }
          }
        }
      }
      
      bestAns.randomImprove();
      bestAns.outputAsAns();
      bestAns.scoreForHuman().deb;
    }
  }

  version (MIXED) {
    struct Cluster {
      Node inlet, outlet, goal;
      Node[] nodes;
      Edge[] edges;
    }

    foreach(goal; goalNodes) {
      foreach(theta; iota(0.0, PI*2, PI*2 / 12)) {

      }
    }
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
  auto initDepth = depth.dup;

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

    if (initDepth[p] > 0 || !g[p].empty) sorted ~= p;
  }

  // zip(size.iota, depth, initDepth).filter!"a[1] > 0".each!deb;
  return sorted;
}

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}
