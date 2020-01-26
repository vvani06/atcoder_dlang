import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

alias Magic = Tuple!(long, "damage", long, "mp");

void main() {
  long H, N; readf("%d %d\n", &H, &N);
  auto Magics = N
    .iota
    .map!(i => readln.split.to!(long[]))
    .map!(m => Magic(m[0], m[1]))
    .array();

  long solve() {
    long[] dp = new long[](10000 * 10000 + 1);
    dp[] = 10000 * 10000 + 1;
    dp[0] = 0;

    foreach(i; 0..H+1) {
      foreach(magic; Magics) {
        dp[i + magic.damage] = min(dp[i + magic.damage], dp[i] + magic.mp);
      }
    }

    long answer = long.max;
    foreach(i; H..10000 * 10000 + 1) {
      answer = min(answer, dp[i]);
    }

    return answer;
  }

  solve().writeln;
}
