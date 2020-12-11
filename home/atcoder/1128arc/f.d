void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto P = N.iota.map!(x => Point(scan!real, scan!real)).array.sort!("a.x < b.x").array;

  real solve() {
    real ans = real.max;

    foreach(i, p; P[0..$-1]) {
      foreach(q; P[i+1..$]) {
        real dx = p.x - q.x;
        real dy = p.y - q.y;
        real norm = dx*dx + dy*dy;
        real size = norm.sqrt;
        dx /= size;
        dy /= size;

        real k = -p.y / dy;
        real circleX = p.x + k * dx;
        deb([p.x, q.x, circleX]);
      }
    }

    return ans;
  }

  writefln("%.10f", solve());
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
