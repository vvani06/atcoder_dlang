void main() {
  debug {
    "==================================".writeln;
    while(true) {
      auto bench =  benchmark!problem(1);
      "<<< Process time: %s >>>".writefln(bench[0]);
      "==================================".writeln;
    }
  } else {
    problem();
  }
}

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto P = scan!long(2 * M).chunks(2);

  auto solve() {
    auto unionFind = UnionFind(N);
    auto pathes = new long[][](N, 0);
    foreach(p; P) {
      unionFind.unite(p[0] - 1, p[1] - 1);
      pathes[p[0] - 1] ~= p[1] - 1;
      pathes[p[1] - 1] ~= p[0] - 1;
    }
    long[][long] groups;
    foreach(i; 0..N) {
      const root = unionFind.root(i);
      if (root in groups) {
        groups[root] ~= i;
      } else {
        groups[root] = [i];
      }
    }

    long ans = 1;
    auto visited = new bool[](N);
    foreach(g; groups) {
      long subAns;
      const n = g.length;
      foreach(b; 0..3^^n) {
        auto t = new long[](n);
        foreach(i; 0..n) {
          t[i] = max(1, (b % 3) * 2);
          b /= 3;
        }
        
        if (g.any!(node => pathes[node].any!(another => t[node] == t[another]))) continue;
        subAns++;
      }

      ans *= subAns;
    }

    return ans;
  }

  static if (is(ReturnType!(solve) == void)) solve(); else solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

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
