void main() {
  problem();
}

struct UnionFind(T) {
  T[] parent;

  this(T size) {
    parent.length = size;
    foreach(i; 0..size) parent[i] = i;
  }

  T root(T x) {
    if (parent[x] == x) return x;
    return parent[x] = root(parent[x]);
  }

  T unite(T x, T y) {
    T rootX = root(x);
    T rootY = root(y);

    if (rootX == rootY) return rootY;
    return parent[rootX] = rootY;
  }

  bool same(T x, T y) {
    T rootX = root(x);
    T rootY = root(y);

    return rootX == rootY;
  }
}

void problem() {
  const N = scan!long;
  const M = scan!long;
  auto F = M.iota.map!(_ => Point(scan!long - 1, scan!long - 1)).array;

  void solve() {
    auto unionFind = UnionFind!long(N);
    auto friendsCount = new long[N];
    auto candidates = new long[N];
    candidates[] = 1;

    foreach(f; F) {
      const rootX = unionFind.root(f.x);
      const united = unionFind.unite(f.x, f.y);
      friendsCount[f.x]++;
      friendsCount[f.y]++;

      if (rootX != united) candidates[united] += candidates[rootX];
    }
    
    long ans = long.min;
    foreach(i; 0..N) {
      ans = max(ans, candidates[unionFind.root(i)]);
    }
    ans.writeln;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
