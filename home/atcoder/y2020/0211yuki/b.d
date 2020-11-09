import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto NK = readln.split.to!(ulong[]);
  auto K = NK[1];
  auto P = readln.split.to!(ulong[]);

  void solve() {
    auto Pd = P.map!(x => cast(double)(x+1) / 2.0f);
    double max = Pd[0..K].sum;
    double current = max;

    foreach(i; K..NK[0]) {
      current += Pd[i] - Pd[i-K];
      if (max < current) {
        max = current;
      }
    }

    writefln("%.10f", max);
  }

  solve();
}
