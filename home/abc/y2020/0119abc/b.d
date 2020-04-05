import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  int N, M; readf("%d %d\n", &N, &M);

  void solve() {
    string answer;
    if (N == M) {
      foreach(i; 0..N) answer ~= '0' + N;
    } else if(N > M) {
      foreach(i; 0..N) answer ~= '0' + M;
    } else {
      foreach(i; 0..M) answer ~= '0' + N;
    }

    writeln(answer);
  }

  solve();
}
