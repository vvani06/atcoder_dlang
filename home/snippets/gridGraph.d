enum AroundDelta {
  RC4 = zip([-1, 0, 1, 0], [0, -1, 0, 1]),
  RC8 = zip([-1, -1, -1, 0, 0, 1, 1, 1], [-1, 0, 1, -1, 1, -1, 0, 1])
}

struct GridGraph(AroundDelta ad) {
  int height, width;
  int index(int r, int c) { return r * width + c; }

  int[][] graph;
  this(int h, int w) {
    width = w;
    height = h;
    graph = new int[][](width * height);

    foreach(r; 0..h) foreach(c; 0..w) {
      auto i = index(r, c);
      static foreach(dr, dc; ad) {{
        auto rr = r + dr;
        auto cc = c + dc;
        if (0 <= rr && rr < h && 0 <= cc && cc < w) {
          auto j = index(rr, cc);
          graph[i] ~= j;
        }
      }}
    }
  }

  auto nodes() { return iota(height * width); }
  ref auto nexts(int node) { return graph[node]; }
}
