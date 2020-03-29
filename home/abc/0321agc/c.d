import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
import std.bigint, std.functional;

void main() {
  auto I = readln.split.to!(long[]);
  auto A = I[0];
  auto B = I[1];
  auto C = I[2];

  bool solve() {
    auto x = C - A - B;
    if (x < 0) return false;

    return 4*A*B < x*x;
  }

  writeln(solve() ? "Yes" : "No");
}
