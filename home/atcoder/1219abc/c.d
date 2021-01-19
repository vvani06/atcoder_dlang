void main() {
  problem();
}

void problem() {
  auto N = scan!long;

  void solve() {
    long ans;

    m: foreach(n; 1..N+1) {
      for(long a = n; a > 0; a /= 10) {
        if (a % 10 == 7) continue m;
      }

      for(long a = n; a > 0; a/= 8) {
        if (a % 8 == 7) continue m;
      }

      ans++;
    }

    ans.writeln;
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
