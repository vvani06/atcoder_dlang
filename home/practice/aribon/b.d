import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto L = readln.chomp.to!int;
  auto N = readln.chomp.to!int;
  auto An = readln.split.to!(int[]);

  int[] solve(int[] ant_points) {
    int min;
    int max;
    foreach(point; ant_points) {
      int left = point - 1;
      int right = L - point;
      int[] candidates = [left < right ? left : right, left < right ? right : left];
      if (min < candidates[0]) min = candidates[0];
      if (max < candidates[1]) max = candidates[1];
    }
    return [min, max];
  }

  solve(An).writeln;
}
