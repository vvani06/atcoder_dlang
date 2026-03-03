
struct Tree {
  int size;
  int[][] graph;

  this(int nodes, int[][] edges) {
    size = nodes;
    graph = new int[][](nodes, 0);
    foreach(u, v; edges.asTuples!2) {
      graph[u] ~= v;
      graph[v] ~= u;
    }
  }

  int degrees(int node) {
    return graph[node].length.to!int;
  }

  void topological(void delegate(int, int[]) fn) {
    auto degrees = graph.map!"a.length".array;
    for(auto queue = DList!int(iota(size).filter!(i => degrees[i] <= 1).array); !queue.empty;) {
      auto cur = queue.front;
      queue.removeFront();

      if (degrees[cur] == -1) continue;
      degrees[cur] = -1;
      fn(cur, graph[cur]);

      foreach(next; graph[cur]) {
        if (--degrees[next] == 1) queue.insertBack(next);
      }
    }
  }
}

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
}
