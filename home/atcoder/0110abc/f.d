void main() {
  problem();
}

void problem() {
  auto X = scan!long;
  auto Y = scan!long;
  
  long solve() {
    const halfY1 = Y/2;
    const halfY2 = Y%2 == 1 ? halfY1 + 1 : halfY1;

    long x = X;
    long ans;
    while(x != Y) {
      if (ans > 10) break;
      ans++;
      [ans - 1, x].deb;

      if (Y > x && x < halfY1 && halfY1 - x < (halfY1*2 - x*2 + 1)) {
        x++;
        continue;
      }

      if (halfY2 >= x) {
        x *= 2;
        continue;
      }

      if (halfY2 < x && (x - halfY2) < (x*2 - halfY1) && (Y - x > 1 + 2*(x - halfY2))) {
        x--;
        continue;
      }

      if (x > Y) {
        x--;
      } else {
        x++;
      }
    }

    return ans;
  }

  solve().writeln;
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
