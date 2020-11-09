import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto I = readln.split.to!(long[]);
  auto W = I[0];
  auto H = I[1];

  long solve() {
    if (W == 1 || H == 1) return 1;
    
    long ans;
    ans += (1 + (W - 1)/2) * (1 + (H - 1)/2);
    ans += (W / 2) * (H / 2);
    return ans;
  }

  solve().writeln();
}
