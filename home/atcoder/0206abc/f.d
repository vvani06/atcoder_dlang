void main() {
  problem();
}

void problem() {
  auto X = scan!real;
  auto Y = scan!real;
  auto R = scan!real;

  auto solve() {
    long ans;

    foreach(real y; (Y - R).to!long..((Y + R).to!long) + 1) {
      // [y, R].deb;
      const x = y == R ? R : cos(asin((y - Y) / R)) * R;
      // x.deb;
      // [X - x, X + x].deb;
      ans += ((X + x).to!long - (X - x).to!long) + 1;
    }

    return ans;
  }

  solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias City = Tuple!(long, "a", long, "t");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
