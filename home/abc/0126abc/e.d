import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

alias Magic = Tuple!(long, "damage", long, "magicPoint");

void main() {
  long H, N; readf("%d %d\n", &H, &N);
  auto Magics = N
    .iota
    .map!(i => readln.split.to!(long[]))
    .map!(m => Magic(m[0], m[1]))
    .array();

  long solve() {
    long[long] dp;
    foreach(magic; Magics) {
      dp[magic.magicPoint] = H - magic.damage;
    }

    long answer = long.max;
    while(true) {
      bool updated = false;
      foreach(usedMagicPoint; dp.keys) {
        foreach(magic; Magics) {
          long used = usedMagicPoint + magic.magicPoint;
          long damaged = dp[usedMagicPoint] - magic.damage;
          if (damaged <= 0) {
            if (answer > used) answer = used;
            continue;
          }
          if (used in dp && dp[used] < damaged) continue;
          dp[used] = damaged;
        }
        updated = true;
      }
      if (!updated) break;
    }

    writeln(answer);

    return 0;
  }

  solve().writeln;
}
