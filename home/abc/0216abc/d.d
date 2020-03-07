import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
import std.bigint, std.functional;

void main() {
  auto NK = readln.split.to!(ulong[]);

  auto N = NK[0];
  auto K = NK[1];
  auto A = readln.split.to!(long[]);

  auto negas = A.filter!(x => x <  0).array.sort!"a > b".array;
  auto posis = A.filter!(x => x >= 0).array.sort!"a < b".array;

  void solve() {
    if (K <= negas.length * posis.length) {
      // マイナス
    }
  }

  solve();
}
