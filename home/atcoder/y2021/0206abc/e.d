void main() {
  problem();
}

class Graph {
  Node[] nodes;
  Path[] pathes;

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
    auto node = new Node(identifier);
    nodes ~= node;
    return node;
  }

  Path addPath(long identifier, long from, long to, long cost) {
    auto path = new Path(identifier, nodes[from], nodes[to], cost);
    pathes ~= path;
    return path;
  }

  auto dijkstra(long start) {
    const nodeSize = nodes.length;
    auto costs = new long[](nodeSize);
    enum INF = 2L ^^ 60;
    costs[] = INF;
    costs[start] = 0;
    
    alias HeapValue = Tuple!(long, "cost", long, "index");
    auto heap = [HeapValue(0, start)].heapify!"a.cost > b.cost";
  
    while(!heap.empty) {
      auto v = heap.front;
      heap.removeFront;
      auto k = v.index;

      foreach(path; nodes[k].pathes) {
        const to = path.to.identifier;

        if (costs[to].chmin(costs[k] + path.cost)) {
          heap.insert(HeapValue(costs[to], to));
        }
      }
    }

    return costs;
  }
}

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto Path = scan!long(M*3).chunks(3).array;

  auto solve() {
    enum INF = 2L ^^ 60;
    auto graph = new Graph();
    foreach(i; 0..N) graph.addNode(i);
    foreach(i, p; Path) graph.addPath(i, p[0] - 1, p[1] - 1, p[2]);

    auto costs = N.iota.map!(i => graph.dijkstra(i)).array;
    foreach(i; 0..N) costs[i][i] = INF;

    // self loop 
    auto loops = new long[](N);
    loops[] = INF;
    Path.filter!"a[0] == a[1]".each!(p => loops[p[0] - 1].chmin(p[2]));

    foreach(i; 0..N) {
      long cost = INF;
      foreach(j; 0..N) {
        cost.chmin(costs[i][j] + costs[j][i]);
      }

      auto ans = min(cost, loops[i]);
      writeln(ans >= INF ? -1 : ans);
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
