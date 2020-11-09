void main() {
  problem();
}

void problem() {
  const N = scan!int;
  const A = scan!(long)(N);

  long[] counts = new long[N+1];
  foreach(a; A) counts[a]++;

  const pairsCounts = counts.map!(x => x <= 0 ? 0 : (x-1)*x/2).array;
  const totalPairsCounts = pairsCounts.sum;

  const pairsCountsLess = counts.map!(x => (x - 1) <= 0 ? 0 : (x-2)*(x-1)/2).array;
  const pairsDecreaseCounts = (N+1).iota.map!(i => pairsCounts[i] - pairsCountsLess[i]).array;

  counts.deb;
  pairsCounts.deb;
  totalPairsCounts.deb;
  pairsCountsLess.deb;
  pairsDecreaseCounts.deb;

  int solve() {
    foreach(a; A) {
      (totalPairsCounts - pairsDecreaseCounts[a]).writeln;
    }
    return 0;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
