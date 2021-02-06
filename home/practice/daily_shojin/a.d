void main() {
  problem();
}

enum INF = long.max / 3;

class Tree {
  long size;
  long pathSize;
  Array!(Array!long) nodes;

  this(long nodeSize, long[] pathes) {
    size = nodeSize + 1;
    nodes.length = size;
    foreach(path; pathes.chunks(2)) {
      pathSize++;
      nodes[path[0]].insert(path[1]);
      nodes[path[1]].insert(path[0]);
    }
  }

  long[] distancesFromTo(long from, long[] to) {
    Array!long ret;
    ret.length = size;
    ret[] = INF;
    ret[from] = 0;
    
    auto queue = DList!long(from);
    while(!queue.empty) {
      auto base = queue.front;
      queue.removeFront();

      const x = ret[base] + 1;
      foreach(n; nodes[base]) {
        if (ret[n] > x) {
          ret[n] = x;
          queue.insertBack(n);
        }
      }
    }
    return to.length.iota.map!(a => ret[to[a]]).array;
  }
}

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto P = scan!long(M*2);
  auto K = scan!long;
  auto G = scan!long(K);

  void solve() {
    auto tree = new Tree(N, P);
    auto distances = G.map!(g => tree.distancesFromTo(g, G)).array;
    distances.deb;
    
    const ROUTES = 2^^K;
    long[][] routes;
    routes.length = K + 1;
    ROUTES.iota.each!(i => routes[i.popcnt] ~= i);

    auto dp = new long[][](ROUTES, K);
    foreach(ref d; dp) d[] = INF;
    dp[$ - 1][] = 0;
    foreach_reverse(rs; 1..K+1) {
      foreach(route; routes[rs]) {
        foreach(i; 0..K) {
          const from = 1 << i;
          if ((route & from) == 0) continue;
            
          foreach(j; 0..K) {
            const to = 1 << j;
            if ((route & to) == 0 || i == j) continue;

            dp[route - to][i] = dp[route - to][i].min(dp[route][j] + distances[i][j]);
            // [i, j, route - to, route, dp[route - to][i], distances[i][j]].deb;
          }
        }
      }
    }
    
    long ans = routes[1].map!(r => dp[r].minElement).minElement;
    writeln(ans == INF ? -1 : ans + 1);
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.functional, core.bitop;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
