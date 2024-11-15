import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  long A, B, C; readf("%d %d %d\n", &A, &B, &C);
  long answer;

  void plusAB() { answer++; A++; B++; }
  void plusAC() { answer++; A++; C++; }
  void plusBC() { answer++; B++; C++; }

  long solve() {
    if (A%2 == B%2 && A%2 != C%2) plusAB;
    if (A%2 == C%2 && B%2 != C%2) plusAC;
    if (B%2 == C%2 && A%2 != C%2) plusBC;

    auto max = [A, B, C].reduce!(max);
    answer += (max - A) / 2;
    answer += (max - B) / 2;
    answer += (max - C) / 2;

    return answer;
  }

  solve().writeln;
}
