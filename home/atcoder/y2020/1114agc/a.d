void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto S = scan!string(N);

  void solve() {

    BitArray[] erasers;
    foreach(i, s; S) {
      bool[] eraser = s.map!(c => c == '0').array;
      // eraser[i] = false;
      erasers ~= BitArray(eraser);
    }

    bool[] base = new bool[N];
    base[] = true;

    BitArray[] erased;
    foreach(i; 0..N) {
      auto nodes = BitArray(base);
      auto next = [i];
      while(!next.empty) {
        foreach(s; next) {
          nodes[s] = false;
        }
        auto origin = nodes.dup;
        foreach(s; next) {
          nodes &= erasers[s];
        }
        next = [];
        foreach(i, b; (origin & ~nodes)) {
          if (b) next ~= i;
        }
      }
      erased ~= nodes;
    }

    long sumDepth, sumTry;
    BitArray x = BitArray(base);
    foreach(i; 0..N) {
      long dfs(BitArray nodes, long select, long depth = 0) {
        depth++;
        nodes &= erased[select];

        bool mada;
        foreach(i; 0..N) {
          if (nodes[i]) {
            dfs(nodes, i, depth);
            nodes &= erased[select];
            mada = true;
          }
        }


        if (!mada) {
          sumTry++;
          sumDepth += depth;
        }

        nodes.deb;
        nodes ^= erased[select];

        return depth;
      }
      dfs(BitArray(base), i);
    }
    [sumDepth, sumTry].deb;
    writefln("%.16f", sumDepth.to!real / sumTry.to!real);
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.bitmanip;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

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


// -----------------------------------------------
