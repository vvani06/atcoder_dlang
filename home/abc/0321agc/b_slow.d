import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto N = readln.chomp.to!int;
  auto A = readln.chomp.map!(c => cast(int)(c - '0')).array;

  int solve() {
    foreach_reverse(i; 0..N-1) {
      A[i+1] -= A[i];
    }
    A.writreln;
  }

  solve().writeln();
}
