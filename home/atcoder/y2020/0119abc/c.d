import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto N = readln.chomp.to!(int);
  auto P = readln.split.to!(int[]);

  void solve() {
    int answer;
    int min = 999999;
    foreach(i; 0..N) {
      min = min < P[i] ? min : P[i];
      if (min >= P[i]) answer++;
    }

    answer.writeln();
  }

  solve();
}
