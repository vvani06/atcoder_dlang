void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto P = scan!long(N);
  auto SORTED = P.dup.sort().array;
  
  void solve() {
    long t;
    long[long] m;
    const SWAPS = N - 1;

    foreach(i; 0..N) {
      if (P[i] < i+1) {
        t += i - P[i] + 1;
        m[P[i]] = i;
        if (t > SWAPS) break;
      }
    }

    if (t != SWAPS) {
      writeln(-1); return;
    }

    m.deb;
    long[] ans;
    foreach(v; m.keys().sort()) {
      long x = m[v];

      [v-1, x].deb;
      foreach_reverse(i; v-1..x) {
        long tmp = P[i];
        P[i] = P[i + 1];
        P[i + 1] = tmp;
        ans ~= i + 1;
      }
    }

    P.deb;
    if (P == SORTED) {
      foreach(a; ans) a.writeln;
    } else {
      writeln(-1);
    }
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
