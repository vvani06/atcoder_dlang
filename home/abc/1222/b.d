import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto size = readln.chomp.to!int;
  auto words = readln.split.to!(string[]);

  void solve() {
    string result;
    foreach(i; 0..size) {
      result ~= words[0][i];
      result ~= words[1][i];
    }

    result.writeln;
  }

  solve();
}
