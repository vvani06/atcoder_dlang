import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto N = readln.chomp.to!int;
  auto An = readln.split.to!(int[]);

  long solve(int[] stick_lengths) {
    int max_around_length;
    foreach(l; stick_lengths.combinations(3)) {
      if (l[0] > l[1] + l[2]) continue;
      if (l[1] > l[0] + l[2]) continue;
      if (l[2] > l[1] + l[0]) continue;
      auto around_length = l.sum;
      if (max_around_length < around_length) max_around_length = around_length;
    }
    return max_around_length;
  }

  solve(An).writeln;
}
