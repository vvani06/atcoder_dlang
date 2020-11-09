import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto abk = readln.split.to!(long[]);
  auto A = abk[0];
  auto B = abk[1];
  auto K = abk[2];

  void solve() {
    auto a = K >= A ? 0 : A - K;
    K -= A - a;
    auto b = K >= B ? 0 : B - K;
    writefln("%s %s", a, b);
  }

  solve();
}
