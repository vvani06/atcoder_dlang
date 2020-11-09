void main() {
  problem();
}

void problem() {
  const N = scan!long;
  const M = scan!long;
  const W = scan!long(N);
  const P = M.iota.map!(_ => Bridge(scan!long, scan!long)).array;

  void solve() {
    Bridge neck = Bridge(long.max, long.max);
    foreach(p; P) {
      if (neck.weight > p.weight || (neck.weight == p.weight && neck.length < p.length)) {
        neck.weight = p.weight;
        neck.length = p.length;
      }
    }
    neck.deb;

    long ans = long.max;
    foreach(weights; W.permutations) {
      long maxWeights;
      foreach(groupSize; 1..N+1) {
        long[] groupWeights = new long[N / groupSize + (N % groupSize == 0 ? 0 : 1)];
        foreach(i; 0..N) {
          groupWeights[i / groupSize] += weights[i];
        }
        maxWeights = groupWeights.maxElement;

        if (neck.weight < maxWeights) continue;

        const cand = (groupWeights.length - 1) * neck.length;
        if (ans > cand) ans = cand;
      }
    }

    writeln(ans == long.max ? -1 : ans);
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
alias Bridge = Tuple!(long, "length", long, "weight");

// -----------------------------------------------
