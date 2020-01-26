import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  int N, K; readf("%d %d\n", &N, &K);
  auto points = readln.split.to!(long[]);
  auto pattern = readln.chomp.map!(s => s == 'r' ? 2 : s == 's' ? 0 : 1).array;

  void solve() {
    long point;
    bool[] win = new bool[N];
    foreach(i; 0..N) {
      auto x = pattern[i];
      if (i >= K && win[i - K] == true && pattern[i - K] == x) continue;
      
      point += points[x];
      win[i] = true;
    }
    point.writeln;
  }

  solve();
}
