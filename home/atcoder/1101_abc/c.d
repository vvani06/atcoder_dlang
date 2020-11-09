void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto P = N.iota.map!(x => Point(scan!long, scan!long)).array;

  bool solve() {
    foreach(ai; 0..N-2) {
      const a = P[ai];
      foreach(bi; ai+1..N-1) {
        const b = P[bi];
        // y = Ax + B
        long vecX = b.x - a.x;
        long vecY = b.y - a.y;
        const g = gcd(vecX.abs, vecY.abs);
        vecX /= g;
        vecY /= g;
        foreach(c; P[bi+1..$]) {
          long vecCX = c.x - a.x;
          long vecCY = c.y - a.y;
          const gg = gcd(vecCX.abs, vecCY.abs);
          vecCX /= gg;
          vecCY /= gg;
          if (vecX == vecCX && vecY == vecCY) return true;
          if (vecX == -vecCX && vecY == -vecCY) return true;
        }
      }
    }

    return false;
  }

  writeln(solve() ? "Yes" : "No");
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
