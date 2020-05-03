void main() {
  problem();
}

void problem() {
  const S = scan;
  auto N = S.length;

  long solve() {
    if (N < 4) return 0;
    
    const P = 2019;
    long ans;

    auto cs = new long[](P);
    cs[0] = 1;

    long x, t = 1;
    foreach_reverse (c; S) {
        x = ((c-'0').to!long * t + x) % P;
        t = (t * 10) % P;
        ans += cs[x];
        ++cs[x];
    }
    return ans;
  }

  long solve2() {
    const MOD = 2019;
    long[long] countsPerMod;
    long answer;

    countsPerMod[0] = 1;
    countsPerMod[1] = 1;
    long acc;

    foreach(c; S) {
      const number = c - '0';
      
      long[long] newCountsPerMod;
      foreach(m; countsPerMod.keys) {
        const next = (10 * m) % MOD;
        if (!(next in newCountsPerMod)) newCountsPerMod[next] = 0;
        newCountsPerMod[next] += countsPerMod[m];
        [m, next, countsPerMod[m], newCountsPerMod[next]].deb;
      }
      "-------------------------".deb;

      countsPerMod = newCountsPerMod;
    }

    return answer;
  }

  solve2().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
import std.bigint, std.functional;

// -----------------------------------------------
