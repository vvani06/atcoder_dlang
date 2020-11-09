void main() {
  problem();
}

void problem() {
  const N = scan!long;
  const M = scan!long;
  
  void solve() {

    const oddStart = M / 2;
    foreach(i, d; iota(2, M+1, 2).array){
      writefln("%s %s", oddStart - i, oddStart - i + d);     
    }
    
    const evenStart = N - (M % 2 == 0 ? M / 2 : M / 2 + 1);
    foreach(i, d; iota(1, M+1, 2).array){
      writefln("%s %s", evenStart - i, evenStart - i + d);     
    }
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
