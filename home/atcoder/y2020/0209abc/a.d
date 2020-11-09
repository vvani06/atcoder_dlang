import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto ST = readln.split.to!(string[]);
  auto AB = readln.split.to!(ulong[]);
  auto U = readln.chomp.to!(string);

  if (U == ST[0]) AB[0]--;
  if (U == ST[1]) AB[1]--;

  writefln("%s %s", AB[0], AB[1]);
}
