import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  long[][] matrix;
  bool[long] numbers;
  foreach(i; 0..3) {
    auto line = readln.split.to!(long[]);
    matrix ~= line;
    foreach(l; line) numbers[l] = false;
  }

  foreach(i; 0..readln.chomp.to!long) {
    auto n = readln.chomp.to!long;
    numbers[n] = true;
  }

  bool solve() {
    bool[][] comb;
    foreach(i; 0..3) {
      comb ~= [numbers[matrix[0][i]], numbers[matrix[1][i]], numbers[matrix[2][i]]];
      comb ~= [numbers[matrix[i][0]], numbers[matrix[i][1]], numbers[matrix[i][2]]];
    }
    comb ~= [numbers[matrix[0][0]], numbers[matrix[1][1]], numbers[matrix[2][2]]];
    comb ~= [numbers[matrix[0][2]], numbers[matrix[1][1]], numbers[matrix[2][0]]];

    foreach(c; comb) {
      if (c.all!(x => x == true)) return true;
    }
    return false;
  }

  writeln(solve() ? "Yes" : "No");
}
