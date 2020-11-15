void main() {
  problem();
}

void problem() {
  auto S = Point(scan!real, scan!real);
  auto G = Point(scan!real, scan!real);

  void solve() {
    real spreadX = G.x - S.x;
    G.y *= -1;
    real spreadY = G.y - S.y;
    S.deb;
    G.deb;
    real vec = spreadX / spreadY;
    vec.deb;
    writefln("%.10f", S.x + -vec * S.y);
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
alias Point = Tuple!(real, "x", real, "y");

// -----------------------------------------------
