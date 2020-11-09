void main() {
  problem();
}

void problem() {
  const N = scan!int;
  const K = scan!int;
  auto V = N.iota.map!(_ => K.iota.map!(_ => scan!long).array.assumeSorted).array;

  long solve() {

    auto usableLeft = new int[N];
    foreach(i; 1..N) {
      const minimum = V[i-1][usableLeft[i - 1]];
      usableLeft[i] = V[i].lowerBound(minimum).length.to!int;
      if (usableLeft[i] == -1) usableLeft[i] = 0;
    }
    usableLeft.deb;

    auto usableRight = new int[N];
    usableRight[] = K;
    {
      const maximum = V[N - 1][K - 1];
      foreach_reverse(i; 0..N-1) {
        usableRight[i] = V[i].lowerBound(maximum + 1).length.to!int;
        if (usableRight[i] == -1) usableRight[i] = K;
      }
    }
    usableRight.deb;

    long ans = powmod(K.to!ulong, N.to!ulong, MOD);
    long reduceLeft = 1;
    long reduceRight = 1;
    foreach(i; 0..N) {
      reduceLeft *= usableLeft[i];
      reduceLeft %= MOD;
      reduceRight *= (K - usableRight[i]);
      reduceRight %= MOD;
    }
    [ans, reduceLeft, reduceRight].deb;

    ans -= reduceLeft;
    if (ans < 0) ans += MOD;

    ans -= reduceLeft;
    if (ans < 0) ans += MOD;

    return ans;
  }

  solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
const ulong MOD = 10^^9 + 7;

// -----------------------------------------------
