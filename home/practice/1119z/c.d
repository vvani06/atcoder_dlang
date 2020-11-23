void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto A = scan!long;
  auto B = scan!long;
  auto D = N.iota.map!(_ => (scan() == "East" ? 1 : -1) * (min(max(scan!long, A), B))).array;

  void solve() {
    long ans = D.sum;
    
    if (ans == 0)
      writeln(0);
    else
      writefln("%s %s", ans < 0 ? "West" : "East", ans.abs);
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

// -----------------------------------------------
