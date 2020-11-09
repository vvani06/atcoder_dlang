void main() {
  problem();
}

void problem() {
  const H = scan!int, W = scan!int, K = scan!int;
  const SHW = H.iota.map!(_ => scan).array;
  int[] choco = new int[W];

  const bitBase = H.iota.map!(x => 1 << x).array;
  foreach(x; 0..W) {
    foreach(i, b; bitBase) choco[x] += SHW[i][x] == '1' ? b : 0;
  }

  int bitCount(int a) {
    int count = (a & 1) == 1;
    for(int i = 1; i <<= 1; i < 1024) {
      count += (a & i) == i;
    }
    return count;
  }

  SHW.deb;
  choco.deb;

  int solve() {
    const whiteCount = choco.map!(x => bitCount(x)).sum;
    if (whiteCount <= K) return 0;

    int[int][int] dp;

    return 0;
  }

  solve().writeln;
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
