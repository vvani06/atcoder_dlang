void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto X = scan!long;
  auto Prices = scan!long(N);

  void solve() {
    N.iota.map!(i => X.bitAt(i) ? Prices[i] : 0).sum.writeln;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, core.bitop;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
bool bitAt(T)(T t, long i){ return bt(cast(size_t*)&t, i) == 1; }
T decAt(T)(T t, long i){ return (t % (10^^(i+1))) / (10^^i); }

// -----------------------------------------------
