void main() {
  problem();
}

void problem() {
  const N = scan!ulong;
  const K = scan!int;
  const steps = K.iota.map!(x => [scan!ulong, 1 + scan!ulong]).array;
  steps.deb;

  ulong solve() {
    ulong ans;
    auto dp = new ulong[N + 1];
    dp[N - 1] = 1;

    auto acc = new ulong[2 * N + 2];
    acc[N - 1] = 1;

    foreach_reverse(i; 0..N-1) {
      ulong cur = 0;

      foreach(s; steps) {
        const l = i + s[0];
        const r = i + s[1];

        const t = (acc[r] > acc[l] ? MOD : 0) + acc[l] - acc[r];
        cur += t;
        cur %= MOD;
      }

      dp[i] = cur;
      acc[i] = (cur + acc[i + 1]) % MOD;
    }

    dp.deb;
    return dp[0];
  }

  solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
const MOD = 998244353;

// -----------------------------------------------
