import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  long A, B, K; readf("%d %d %d\n", &A, &B, &K);

  void solve() {
    if (A+K > B) {
      foreach(i; A..B+1) i.writeln;
      return;
    }

    auto left_max = A+K;
    auto right_min = B-K+1 > left_max? B-K+1 : left_max;
    
    foreach(i; A..left_max) writeln(i);
    foreach(i; right_min..B+1) writeln(i);
  }

  solve();
}
