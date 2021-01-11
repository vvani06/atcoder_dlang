void main() {
  problem();
}

class Tree {
  Node[long] nodes;
  Path[long] pathes;

  class Path {
    long identifier;
    Node from, to;

    this(long identifier, Node from, Node to) {
      this.identifier = identifier;
      this.from = from;
      this.to = to;
      from.add(to);
      to.add(from);
    }
  }

  class Node {
    Node[] next;
    long[] nextIdentifiers;
    long identifier;
    long value;

    this(long identifier) {
      this.identifier = identifier;
    }

    void add(Node other) {
      next ~= other;
      nextIdentifiers ~= other.identifier;
    }
  }

  Node addNode(long identifier) {
    return nodes[identifier] = new Node(identifier);
  }

  Path addPath(long identifier, long from, long to) {
    return pathes[identifier] = new Path(identifier, nodes[from], nodes[to]);
  }

  void traverse(long from) {
    bool[long] visited;

    auto next = [nodes[from]];
    while(!next.empty) {
      Node[] queue;
      foreach(node; next) {
        visited[node.identifier] = true;
        node.identifier.deb;

        foreach(n; node.next) {
          if (n.identifier in visited) continue;
          queue ~= n;
        }
      }
      next = queue;
    }
  }
}

void problem() {
  auto N = scan!long;
  auto Path = scan!long(N*2 - 2).chunks(2).array;
  auto Q = scan!long;
  auto Query = scan!long(Q*3).chunks(3).array;

  void solve() {
    auto tree = new Tree();
    foreach(i; 1..N+1) tree.addNode(i);
    foreach(i, p; Path) tree.addPath(i, p[0], p[1]);

    tree.traverse(3);
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

// -----------------------------------------------
