import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto N = readln.chomp.to!int;
  auto A = readln.chomp.map!(c => cast(int)(c - '1')).array;

  int solve() {

    bool isOddTriangle(T)(long N, T arr) {
      bool isOdd;
      foreach(i, a; arr) {
        if (a != 1) continue;

        auto k = i;
        if ((N & k) == k) isOdd ^= true;
        debug [N, k, N&k, isOdd].writeln;
      }
      return isOdd;
    }
    
    if (isOddTriangle(N-1, A)) return 1;
    if (A.any!(a => a == 1)) return 0;
    
    return isOddTriangle(N-1, A.map!"a/2".array) ? 2 : 0;
  }

  solve().writeln();
}
