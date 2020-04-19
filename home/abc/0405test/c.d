void main() {
  problem();
}

void problem() {
  const An = scan!int(3);
  const N = An.sum;

  long solve() {
    long ans;
    base:foreach(perm; N.iota.permutations) {
      auto one = perm[0..An[0]];
      auto two = perm[An[0]..An[0]+An[1]];
      auto three = perm[An[0]+An[1]..$];
      auto grid = [one, two, three];
      
      for(int i = 1; i<An[0]; i++) if (one[i] <= one[i-1]) continue base;
      for(int i = 1; i<An[1]; i++) if (two[i] <= two[i-1]) continue base;
      for(int i = 1; i<An[2]; i++) if (three[i] <= three[i-1]) continue base;

      foreach(y; 1..3) {
        foreach(x; 0..3) {
          if (grid[y].length <= x) continue;
          if (grid[y][x] <= grid[y-1][x]) continue base;
        }
      }

      deb([one, two, three]);

      ans++;
    }

    return ans;
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
