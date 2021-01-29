void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto T = scan!long;
  auto P = M.iota.map!(_ => Point(scan!long, scan!long)).array;

  void solve() {
    P ~= Point(T, T);
    long batt = N;

    long prev = 0;
    foreach(p; P) {
      batt.deb;
      batt -= p.x - prev;
      if (batt <= 0) {
        writeln("No");
        return;
      }

      batt += p.y - p.x;
      batt = min(batt, N);
      prev = p.y;
    }

    writeln("Yes");
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
alias Point = Tuple!(long, "x", long, "y");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
