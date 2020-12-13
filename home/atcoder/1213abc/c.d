void main() {
  problem();
}

void problem() {
 
  ulong comb(ulong a, ulong b) {
    if (b == 0) {
      return 1;
    } else {
      return comb(a - 1, b - 1) * a / b;
    }
  }

  void solve(ulong l) {
    comb(l - 1, 11).writeln;
  }

  solve(scan!ulong);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

alias Station = Tuple!(long, "cost", long, "offset", long, "frequency");

// -----------------------------------------------
