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
    long price;
    long value;
 
    this(long identifier, long price) {
      this.identifier = identifier;
      this.price = price;
    }
 
    void add(Node other) {
      next ~= other;
      nextIdentifiers ~= other.identifier;
    }
  }
 
  Node addNode(long identifier, long price) {
    return nodes[identifier] = new Node(identifier, price);
  }
 
  Path addPath(long identifier, long from, long to) {
    return pathes[identifier] = new Path(identifier, nodes[from], nodes[to]);
  }
 
  void traverse(long from, long distance) {
    distance.deb;
    nodes[from].value = distance;
    [from, nodes[from].value].deb;
    foreach(n; nodes[from].next) {
      if (n.value == 0) traverse(n.identifier, distance + 1);
    }
  }
}

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto PAIRS = scan!long(M*2);
  auto Pairs = PAIRS.chunks(2).array;
  auto K = scan!long;
  auto Route = scan!long(K);

  long solve() {
    foreach(r; Route) {
      if (!PAIRS.canFind(r)) return -1;
    }

    auto tree = new Tree();
    foreach(i; 1..N+1) tree.addNode(i, 0);
    foreach(i, p; Pairs) tree.addPath(i, p[0], p[1]);
    tree.traverse(Route[0], 0);

    auto values = Route.map!(k => tree.nodes[k].value).array;
    long ans;
    foreach(i; 0..K) {
      
    }

    return ans;
  }

  solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias City = Tuple!(long, "a", long, "t");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
