import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto I = readln.split.to!(long[]);
  auto N = I[0];
  auto M = I[1];
  long[long] decimals;

  foreach(i; 0..M) {
    I = readln.split.to!(long[]);
    auto key = N - I[0];

    if (key in decimals && I[1] != decimals[key]) {
      writeln(-1);
      return;
    }

    if (N != 1 && key == N-1 && I[1] == 0) {
      writeln(-1);
      return;
    }

    decimals[key] = I[1];
  }

  ulong solve() {
    long ans;
    long keta = 1;

    foreach(i; 0..N) {
      if (i in decimals) {
        ans += keta * decimals[i];
      } else {
        ans += keta * (i == N-1 && N > 1 ? 1 : 0);
      }

      keta *= 10;
    }

    return ans;
  }

  solve().writeln;
}
