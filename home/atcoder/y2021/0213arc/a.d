void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto LR = scan!long(N*2).chunks(2);

  auto solve() {
    enum MAX = 10^^6 + 1;
    auto acc = new long[](MAX);

    long numComb(long l, long r) {
      if (r == 0) return 1;
      if (r - l < l) return 0;

      // long ret;
      // while(l <= r) {
      //   ret += l == r ? 1 : 2;
      //   l++; r--;
      // }

      const a = r - l - l + 1;
      return a*(a+1)/2;
    }

    foreach(lr; LR) {
      const l = lr[0];
      const r = lr[1];
      numComb(l, r).writeln;
    }

    return;
  }

  static if (is(ReturnType!(solve) == void)) solve(); else solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }

// -----------------------------------------------