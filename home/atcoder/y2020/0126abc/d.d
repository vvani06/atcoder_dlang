import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto H = readln.chomp.to!(ulong);

  void solve() {
    ulong count;
    ulong monsters = 1;
    while(true) {
      if (H == 0) break;

      if (H == 1) {
        H = 0;
      } else {
        H /= 2;
      }
      count += monsters;
      monsters *= 2;
    }

    writeln(count);
  }

  solve();
}
