void main() {
  problem();
}

void problem() {

  ulong MOD = 10^^9 + 7;

  long solve(long field, long blue, long red) {
    if (blue + red > field) return 0;

    const bluePattern = powmod(field - blue.unsigned + 1, 2UL, MOD);
    long redPattern = powmod(field - red.unsigned + 1, 2UL, MOD);
  
    long allPattern = bluePattern * redPattern;
    allPattern %= MOD;
    [bluePattern, redPattern, allPattern].deb;
    
    ulong redu;
    ulong l = field - blue + 1;
    redu += blue * l;
    redu += (l + l - (red - 1) * 2) * (red - 1) / 2 / 2;
    redu.powmod(2UL, MOD).deb;
    allPattern -= redu.powmod(2UL, MOD);
    if (allPattern < 0) allPattern += MOD;

    return allPattern;
  }

  const T = scan!long;
  foreach(_; 0..T) {
    const N = scan!long;
    const A = scan!long;
    const B = scan!long;
    solve(N, max(A, B), min(A, B)).writeln;
  }
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