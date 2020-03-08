import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto I = readln.split.to!(long[]);
  auto A = I[0];
  auto B = I[1];

  long solve() {
    foreach(i; 0..30000) {
      auto cp8 = (i * 108) / 100 - i;
      auto cp10 = (i * 110) / 100 - i;

      if (cp8 == A && cp10 == B) return i;
    }
    return -1;
  }


  solve().writeln;
}
