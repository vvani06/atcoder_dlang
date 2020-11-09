void main() {
  problem();
}

void problem() {
  const bingo = 3.iota.map!(_ => scan!int(3)).array;
  bool[][] hit = [[false, false, false], [false, false, false], [false, false, false]];
  const numbers = (scan!int()).iota.map!(_ => scan!int).array;

  long solve() {
    foreach(i; numbers) {
      foreach(x; 0..3) {
        foreach(y; 0..3) {
          if (bingo[x][y] == i) hit[x][y] = true;
        }
      }
    }

    return
      (hit[0][0] && hit[0][1] && hit[0][2]) || (hit[1][0] && hit[1][1] && hit[1][2]) || (hit[2][0] && hit[2][1] && hit[2][2]) ||
      (hit[0][0] && hit[0][1] && hit[0][2]) || (hit[1][0] && hit[1][1] && hit[1][2]) || (hit[2][0] && hit[2][1] && hit[2][2]) ||

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
