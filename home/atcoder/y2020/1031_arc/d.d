void main() {
  problem();
}

void problem() {
  const N = scan!long;
  const K = scan!long;

  void solve() {
    long[][] dp;
    foreach(i; 0..N+1) dp ~= new long[N+1];

    foreach(n; 1..N+1) {
      foreach_reverse(k; 1..n+1) {
        if (k == n) {
          dp[n][k] = 1;
          continue;
        }
        dp[n][k] = dp[n-1][k-1];
        if (2*k <= n) {
          dp[n][k] += dp[n][2*k];
          dp[n][k] %= MOD;
        }
      }
    }
    dp[N][K].writeln;
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
enum MOD = 998244353L;

// -----------------------------------------------
