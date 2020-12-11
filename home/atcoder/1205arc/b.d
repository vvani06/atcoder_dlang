void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto T = scan;
  enum S = "110";
  enum LOOP = 10L ^^ 10;

  long solve() {
    if (N == 1) {
      if (T == "0") return LOOP;
      if (T == "1") return 2 * (LOOP);
    }
    if (N == 2) {
      if (T == "00") return 0;
      if (T == "01") return LOOP - 1;
      if (T == "10") return LOOP;
      if (T == "11") return LOOP;
    }
    if (N == 3) {
      if (T == "110") return LOOP;
      else if (T == "101") return LOOP - 1;
      else if (T == "011") return LOOP - 1;
      return 0;
    }

    const l = 1+N/3;
    string ss;
    foreach(i; 0..1+2*N/3) ss ~= S;

    long offset = -1;
    foreach(i; 0..3) {
      if (ss[i..i+N] == T) offset = i;
    }

    if (offset == -1) {
      return 0;
    }

    long ans = (3*LOOP - offset - N + 3) / 3;
    return ans;
  }

  solve().writeln;
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
