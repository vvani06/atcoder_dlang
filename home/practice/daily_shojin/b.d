void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto A = scan!long(N).sort().array;

  void solve() {
    auto acc = new long[](N + 1);
    foreach(i; 1..N+1) acc[i] = acc[i - 1] + A[i - 1];

    acc.deb;
    
    long ans = 0;
    foreach(i; 1..N) {
      [acc[i], A[i]].deb;
      if (acc[i] * 2 < A[i]) ans = i;
    }

    (N - ans).writeln;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.functional, core.bitop;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
