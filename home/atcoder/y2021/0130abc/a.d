void main() {
  problem();
}

void problem() {
  auto A = scan!long;
  auto B = scan!long;
  auto C = scan!long;

  void solve() {
    bool t = C == 0;
    foreach(i; 0..2000) {
      if (t) {
        A--;
        if (A == -1) {
          writeln("Aoki");
          return;
        }
      } else {
        B--;
        if (B == -1) {
          writeln("Takahashi ");
          return;
        }
      }

      t ^= true;
    }
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
