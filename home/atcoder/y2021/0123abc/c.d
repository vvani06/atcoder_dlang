void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto A = scan!long(N);

  void solve() {
    long ans = 0;
    long current;

    foreach(l; 0..N) {
      long x = A[l];
      foreach(r; l..N) {
        x = min(x, A[r]);
        ans = max(ans, x*(r-l+1));
      }
    }

    ans.writeln;
  }

  // "10 ".repeat(10000).joiner(" ").deb;

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
alias Mark = Tuple!(long, "y", long, "x", char, "mark");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
