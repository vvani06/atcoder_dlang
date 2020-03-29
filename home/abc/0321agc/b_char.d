import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto N = readln.chomp.to!int;
  auto A = readln.chomp.map!(c => cast(char)(c - 1)).array;

  char[char[]] memo;
  memo["00"] = '0';
  memo["11"] = '0';
  memo["22"] = '0';
  memo["01"] = '1';
  memo["10"] = '1';
  memo["12"] = '1';
  memo["21"] = '1';
  memo["02"] = '2';
  memo["20"] = '2';

  int solve() {
    foreach_reverse(row; 0..N) {
      foreach(i; 1..row+1) {
        A[N-i] = memo[A[N-i-1..N-i+1]];
      }
    }
    return A[N-1] - '0';
  }

  solve().writeln();
}
