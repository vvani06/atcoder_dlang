void main() {
  problem();
}

void problem() {

  long pattern(Point a, Point b, Point c) {
    if (b.x == c.x) return 1;
    if (b.x <  a.x) return 3;
    if (c.y == b.y) return 4;
    return 2;
  }

  long solve(Point a, Point b, Point c) {
    long pat = pattern(a, b, c);

    long naname = min(a.x.abs, a.y.abs);
    long tateyoko = max(a.x.abs, a.y.abs) - naname;
    long transform = pat == 2 ? 0 : pat == 4 ? 2 : 1;

    return naname*2 + tateyoko*2 + transform;
  }

  auto T = scan!long;
  foreach(_; 0..T) {
    Point[] P;
    P ~= Point(scan!long, scan!long);
    P ~= Point(scan!long, scan!long);
    P ~= Point(scan!long, scan!long);
    auto sorted = P.sort!"a.x + a.y < b.x + b.y".array;
    solve(sorted[0], sorted[1], sorted[2]).writeln;
  }
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
