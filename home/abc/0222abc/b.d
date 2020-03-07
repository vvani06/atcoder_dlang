import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto I = readln.split.to!(long[]);
  auto N = I[0];
  auto K = I[1];

  long solve() {
    long ketasu = 1;
    for(auto i = K; N >= i; i *= K) {
      ketasu++;
    }

    return ketasu;
  }

  solve().writeln;
}
