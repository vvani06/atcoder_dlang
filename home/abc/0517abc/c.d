void main() {
  problem();
}

void problem() {
  const A = scan!real;
  const B = scan!real;
  const H = scan!real;
  const M = scan!real;

  void solve() {
    real thetaHour = ((H / 12L) + (M / 720L)) * 2 * PI;
    real thetaMinute = (M / 60L) * 2 * PI;

    real hx = sin(thetaHour) * A;
    real hy = cos(thetaHour) * A;

    real mx = sin(thetaMinute) * B;
    real my = cos(thetaMinute) * B;

    deb([hx, hy, (hx.pow(2) + hy.pow(2)).sqrt]);
    deb([mx, my, (mx.pow(2) + my.pow(2)).sqrt]);

    writefln("%.16f", ((hx - mx).pow(2) + (hy - my).pow(2)).sqrt);
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
