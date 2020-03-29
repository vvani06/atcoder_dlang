import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
import std.bigint, std.functional;

void main() {
  auto I = readln.split.to!(long[]);
  auto N = I[0] + 1;
  auto P = I[1];
  auto S = readln.chomp;

  void solve() {
    ulong answer;
    foreach(size; 1..N) {
      foreach(offset; 0..N-size) {
        auto number = BigInt(S[offset..offset+size]);
        if (number % P == 0) answer++;
      }
    }
    answer.writeln;
  }

  solve();
}
