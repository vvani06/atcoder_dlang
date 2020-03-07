import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

alias FromTo = Tuple!(int, "from", int, "to");
alias Identifiers = int[int];

class UnionFind {
  int[] parent;

  this(int size) {
    parent = new int[size];
    foreach(i; 0..size) parent[i] = i;
  }

  int root(int index) {
    return parent[index] == index ? index : root(parent[index]);
  }

  void unite(int a, int b) {
    auto root_a = root(a);
    auto root_b = root(b);
    if (root_a == root_b) return;

    parent[root_a] = root_b;
  }

  bool same(int a, int b) {
    return root(a) == root(b);
  }
}

void main() {
  int N, M, K; readf("%d %d %d\n", &N, &M, &K);

  Identifiers[int] friends;
  Identifiers[int] blocked;

  auto unionFind = new UnionFind(N);
  foreach(i; 0..M) {
    int a, b; readf("%d %d\n", &a, &b);
    unionFind.unite(a-1, b-1);
    friends[a-1][b-1] = true;
    friends[b-1][a-1] = true;
  }

  foreach(i; 0..K) {
    int a, b; readf("%d %d\n", &a, &b);
    blocked[a-1][b-1] = true;
    blocked[b-1][a-1] = true;
  }

  void solve() {
    int[] ans = new int[N];
    int[int] root_count;
    foreach(i; 0..N) {
      auto root = unionFind.root(i);

      int count;
      if (i in root_count) {
        count = root_count[unionFind.root(i)];
      } else {
        foreach(j; 0..N) {
          if (i == j) continue;
          if (unionFind.same(i, j)) count++;
        }
      }

      bool[int] excludes;
      foreach(j; i in friends ? friends[i].keys.filter!(x => unionFind.root(x) == root).array : []) excludes[j] = true;
      foreach(j; i in blocked ? blocked[i].keys.filter!(x => unionFind.root(x) == root).array : []) excludes[j] = true;

      root_count[unionFind.root(i)] = count;
      ans[i] = count;
    }
    ans.map!(x => x.to!string).joiner(" ").writeln;
    return;
  }

  solve();
}
