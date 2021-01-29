void main() {
  problem();
}

void problem() {
  auto N = scan!ulong;
  auto K = scan!ulong;
  auto S = scan;

  const pat = [
    "RP": "P", "PR": "P",
    "PS": "S", "SP": "S",
    "SR": "R", "RS": "R",
    "RR": "R",
    "PP": "P",
    "SS": "S",
  ];

  void solve() {
    string s = S ~ S;
    while(K > 0) {
      K--;
      string next;
      foreach(i; 0..s.length/2) {
        next ~= pat[s[i*2..i*2+2]];
      }
      s = next ~ next;
      s.deb;
    }

    s[0].writeln;
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
