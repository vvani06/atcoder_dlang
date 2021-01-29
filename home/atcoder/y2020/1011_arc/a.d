void main() {
  problem();
}

void problem() {
  auto N = scan!(long)(4);
  N.deb;

  string solve() {
    const sum = N.sum;
    foreach(i; 1..16) {
      long ate;
      if ((i & 1) == 1) ate += N[0];
      if ((i & 2) == 2) ate += N[1];
      if ((i & 4) == 4) ate += N[2];
      if ((i & 8) == 8) ate += N[3];
      if (ate == sum - ate) return "Yes";
    }
    
    return "No";
  }

  solve.writeln;
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
