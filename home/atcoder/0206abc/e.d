void main() {
  problem();
}

class Graph {
  Node[long] nodes;
  Path[long] pathes;

  class Path {
    long identifier;
    Node from, to;
    long cost;

    this(long identifier, Node from, Node to, long cost) {
      this.identifier = identifier;
      this.from = from;
      this.to = to;
      this.cost = cost;
      from.add(this);
    }
  }

  class Node {
    Node[] next;
    long[] nextIdentifiers;
    Path[] pathes;
    long identifier;

    this(long identifier) {
      this.identifier = identifier;
    }

    void add(Path p) {
      pathes ~= p;
      next ~= p.to;
      nextIdentifiers ~= p.to.identifier;
    }
  }

  Node addNode(long identifier) {
    return nodes[identifier] = new Node(identifier);
  }

  Path addPath(long identifier, long from, long to, long cost) {
    return pathes[identifier] = new Path(identifier, nodes[from], nodes[to], cost);
  }

  auto bellmanFord(long start) {
    const nodeSize = nodes.length;
    auto costs = new long[nodeSize + 1];
    enum INF = 2L ^^ 60;
    costs[] = INF;
    costs[start] = 0;

    bool hasEffectiveLoop;
    bool[long] effectedNodeIdentifiers;
    foreach(x; 0..nodeSize) {
      foreach(i, node; nodes) {
        if (costs[i] == INF) continue;

        foreach(p; node.pathes) {
          const ni = p.to.identifier;
          if (costs[ni].chmin(costs[i] + p.cost) && x == nodeSize - 1) {
            hasEffectiveLoop = true;
            effectedNodeIdentifiers[ni] = true;
          }
        }
      }
    }

    auto afterLoop = costs.dup;
    foreach(i; effectedNodeIdentifiers.keys) afterLoop[i] = INF;
    foreach(x; 0..nodeSize) {
      foreach(i, node; nodes) {
        if (afterLoop[i] == INF) continue;

        foreach(p; node.pathes) {
          const ni = p.to.identifier;
          if (afterLoop[ni].chmin(afterLoop[i] + p.cost)) {
            effectedNodeIdentifiers[ni] = true;
          }
        }
      }
    }

    return tuple(costs, hasEffectiveLoop, effectedNodeIdentifiers);
  }
}

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto Path = scan!long(M*3).chunks(3).array;

  void solve() {
    auto graph = new Graph();
    foreach(i; 1..N+1) graph.addNode(i);
    foreach(i, p; Path) graph.addPath(i, p[0], p[1], -p[2]);

    const bf = graph.bellmanFord(1);
    bf.deb;

    if (bf[1] && (N in bf[2])) {
      "inf".writeln;
    } else {
      (bf[0][N] * -1).writeln;
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
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }

// -----------------------------------------------
