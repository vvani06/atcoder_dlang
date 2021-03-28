void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto A = scan!long(N);
  auto B = scan!long(N);

  void solve() {
    long[] c;

    long aMax = 0; 
    long bMax = 0;
    long a;
    long ab;

    foreach(i; 0..N) {
      aMax = max(aMax, A[i]);
      bMax = max(bMax, B[i]);

      if (aMax*B[i] > ab) {
        ab = aMax*B[i];
        bMax = 0;
      }
      c ~= ab;
    }

    c.each!(a => a.writeln);
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
import std.bigint, std.functional;

// -----------------------------------------------
