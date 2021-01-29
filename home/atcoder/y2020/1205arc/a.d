void main() {
  problem();
}

void problem() {
  auto N = scan!long;

  void solve() {
    long x = 2;
    foreach(n; 3..31) {
      x = x * n / gcd(x, n);
    }
    x++;

    foreach(n; 2..31) (x % n).deb;
    
    x.writeln;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.bitmanip;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------







/*





5
7
13
61
61
421
841
2521
2521
27721
27721
360361
360361
360361
720721
12252241
12252241
232792561
232792561
232792561
232792561
5354228881
5354228881
26771144401

*/