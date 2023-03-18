
struct UnionFind {
  int[] parent;
  int[] sizes;
 
  this(int size) {
    parent = size.iota.array;
    sizes = 1.repeat(size).array;
  }
 
  int root(int x) {
    if (parent[x] == x) return x;
    return parent[x] = root(parent[x]);
  }

  int size(int x) {
    return sizes[root(x)];
  }
 
  int unite(int x, int y) {
    int rootX = root(x);
    int rootY = root(y);
 
    if (rootX == rootY) return rootY;
 
    if (sizes[rootX] < sizes[rootY]) {
      sizes[rootY] += sizes[rootX];
      return parent[rootX] = rootY;
    } else {
      sizes[rootX] += sizes[rootY];
      return parent[rootY] = rootX;
    }
  }
 
  bool same(int x, int y) {
    int rootX = root(x);
    int rootY = root(y);
 
    return rootX == rootY;
  }
}
