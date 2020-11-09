import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
import std.bigint, std.functional;

void main() {
  auto I = readln.split.to!(BigInt[]);
  auto N = BigInt(I[0]);
  auto A = BigInt(I[1]);
  auto B = BigInt(I[2]);

  BigInt solve() {
    auto loopSize = A + B;
    auto looped = N / loopSize;
    auto mod = N % loopSize;

    return looped * A + (mod <= A ? mod : A);
  }

  solve().writeln();
}
