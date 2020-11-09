void main() {
  problem();
}

void problem() {
  const N = scan!long;
  const K = scan!long;

  long solve() {
    long ans;

    long[long] counts;
    long minimal = 0;
    long maximam = N;
    foreach(i; 1..N+2) {
      counts[i] = maximam - minimal + 1;
      minimal += i;
      maximam += (N - i);
    }

    foreach(n; K..N+2) {
      ans = (ans + counts[n]) % MOD;
    }

    return ans;
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

const MOD = 100_000_000_7;

// -----------------------------------------------
