import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto H = readln.chomp.to!(int);
  auto W = readln.chomp.to!(int);
  auto N = readln.chomp.to!(int);

  auto sizePerPaint = H > W ? H : W;
  writeln(N / sizePerPaint + (N % sizePerPaint == 0 ? 0 : 1));
}
