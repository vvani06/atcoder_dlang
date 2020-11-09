void main() {
  problem();
}

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

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto K = scan!long;
  auto F = M.iota.map!(_ => Point(scan!long - 1, scan!long - 1)).array;
  auto B = K.iota.map!(_ => Point(scan!long - 1, scan!long - 1)).array;

  void solve() {
    auto unionFind = UnionFind(N);
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

    bool[long][] blockList;
    blockList.length = N;
    foreach(b; B) {
      blockList[b.x][b.y] = true;
      blockList[b.y][b.x] = true;
    }

    friendsCount.deb;
    candidates.deb;

    foreach(i; 0..N) {
      long ans;
      const root = unionFind.root(i);
      ans -= friendsCount[i];
      ans += candidates[root] - 1;
      foreach(b; blockList[i].keys) {
        if (unionFind.same(i, b)) ans--;
      }
      ans.writeln;
    }
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
