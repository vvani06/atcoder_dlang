void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto K = scan!long;

  void solve() {
    ulong all = N^^3;
    ulong noK = (N - 1)^^3;
    ulong moreK = N - K;
    ulong lessK = K - 1;
    ulong oneKNG = 3 * (moreK^^2 + lessK^^2);
    
    writefln("%.20f", cast(real)(all - noK - oneKNG) / cast(real)all);
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.bigint, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
