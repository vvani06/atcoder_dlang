void main() {
  problem();
}

void problem() {
  const A = scan!long;
  const B = scan!long;
  const C = scan!long;
  const D = scan!long;
  const MOD = 998_244_353;

  long solve() {
    long[][] dp;
    dp.length = 3001;
    foreach(i; 0..3001) dp[i].length = 3001;

    Point[] candidates = [Point(A, B)];
    dp[A][B] = 1;
    while(true) {
      Point[] nextCandidates = [];
      foreach(c; candidates) {
        if (c.x != C) {
          const before = dp[c.x + 1][c.y];
          const after = (dp[c.x][c.y] * c.y) % MOD;
          if (before == 0) {
            dp[c.x + 1][c.y] = after;
          } else {
            dp[c.x + 1][c.y] = (before + after - 1) % MOD;
            dp[c.x + 1][c.y].deb;
          }
          nextCandidates ~= Point(c.x + 1, c.y);
        }
        if (c.y != D) {
          const before = dp[c.x][c.y + 1];
          const after = (dp[c.x][c.y] * c.x) % MOD;
          if (before == 0) {
            dp[c.x][c.y + 1] = after;
          } else {
            dp[c.x][c.y + 1] = (before + after - 1) % MOD;
            dp[c.x][c.y + 1].deb;
          }
          nextCandidates ~= Point(c.x, c.y + 1);
        }
      }

      if (nextCandidates.length == 0) break;
      candidates = nextCandidates;
    }

    return dp[C][D];
  }

  solve().writeln;
}

// ---------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
