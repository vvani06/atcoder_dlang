import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  ulong N, M; readf("%d %d\n", &N, &M);
  auto H = readln.split.to!(ulong[]).sort();

  void solve() {
    if (M >= N) {
      writeln(0);
      return;
    }

    ulong count;
    foreach(h; H[0..N-M]) {
      count += h;
    }
    writeln(count);
  }

  solve();
}
