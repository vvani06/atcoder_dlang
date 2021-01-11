
struct UnionFind {
  long[] parent;

  this(long size) {
    parent.length = size;
    foreach(i; 0..size) parent[i] = i;
  }

  long root(long x) {
    if (parent[x] == x) return x;
    return parent[x] = root(parent[x]);
  }

  long unite(long x, long y) {
    long rootX = root(x);
    long rootY = root(y);

    if (rootX == rootY) return rootY;
    return parent[rootX] = rootY;
  }

  bool same(long x, long y) {
    long rootX = root(x);
    long rootY = root(y);

    return rootX == rootY;
  }
}
