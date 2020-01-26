import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  ulong H, N; readf("%d %d\n", &H, &N);
  auto Magic = N
    .iota
    .map!(i => readln.split.to!(ulong[]))
    .array()
    .sort!((a, b) => a[0] < b[0]);

  ulong solve() {
    ulong[] mostEfficientMagic;
    {
      double max_efficiency = 0.0f;
      foreach(magic; Magic) {
        double efficiency = 1.0f * magic[0] / magic[1];
        efficiency.writeln;
        if (max_efficiency < efficiency) {
          max_efficiency = efficiency;
          mostEfficientMagic = magic;
        }
      }
    }

    ulong usedMagicPoint;
    while(H >= 1) {
      if (H < mostEfficientMagic[0]) {
        foreach(magic; Magic) {
          if (H > magic[0]) continue;

          usedMagicPoint += magic[1];
          break;
        }
        return usedMagicPoint;
      }

      usedMagicPoint += mostEfficientMagic[1];
      H -= mostEfficientMagic[0];
      usedMagicPoint.writeln;
    }

    return usedMagicPoint;
  }

  solve().writeln;
}
