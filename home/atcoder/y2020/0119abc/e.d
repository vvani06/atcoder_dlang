import std.numeric, std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

import std.bigint, std.functional;

BigInt gcd(BigInt a, BigInt b) {
  if (b == 0) return a;
  return memoize!gcd(b, a % b);
}

T lcm(T)(in T a, in T b) {
  return a / memoize!gcd(a,b) * b;
}


void main() {
  auto N = readln.chomp.to!(int);
  auto A = readln.split.to!(ulong[]).map!(i => BigInt(i)).array;

  void solve() {
    BigInt lcm = A[0];
    foreach(Ai; A[1..N]) {
       lcm = lcm.lcm(Ai);
    }

    BigInt answer;
    foreach(Ai; A) {
      answer += lcm / Ai;
      answer %= 1000000007;
    }

    answer.writeln;
  }

  solve();
}
