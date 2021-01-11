void main() {
  problem();
}

struct Tree {
  Node[long] nodes;
  Path[long] pathes;

  struct Path {
    long identifier;
    Node from, to;

    this(long identifier, Node from, Node to) {
      this.identifier = identifier;
      this.from = from;
      this.to = to;
      from.add(to);
      // to.add(from);
    }
  }

  struct Node {
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

  long[long] memoTraverse;
  long traverse(long from) {
    if (from in memoTraverse) return memoTraverse[from];

    long maxPrice = long.min;
    foreach(n; nodes[from].next) {
      maxPrice = max(maxPrice, n.price);
      maxPrice = max(maxPrice, traverse(n.identifier));
    } 
    
    memoTraverse[from] = maxPrice;
    return maxPrice;
  }
}

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto A = scan!long(N);
  auto Path = scan!long(M*2).chunks(2).array;

  void solve() {
    auto tree = new Tree();
    foreach(i; 1..N+1) tree.addNode(i, A[i-1]);
    foreach(i, p; Path) tree.addPath(i, p[0], p[1]);

    long ans = long.min;
    foreach(i; 1..N+1) {
      auto p = tree.traverse(i);
      if (p == long.min) continue;

      ans = max(ans, p - tree.nodes[i].price);
    }

    ans.writeln;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
