void main() {
  problem();
}

const MOD = 10U^^9 + 7;

void problem() {
  const K = scan!int;
  const S = scan;

  void solve() {
    ulong allPatterns = powmod(26U, S.length + K, MOD);
    ulong notContainsSingleCharPatterns = powmod(25U, S.length + K, MOD);

    allPatterns = (allPatterns - notContainsSingleCharPatterns) % MOD;
    allPatterns = (allPatterns - notContainsSingleCharPatterns) % MOD;
    allPatterns.deb;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
