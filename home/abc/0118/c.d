import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  int N, M; readf("%d %d\n", &N, &M);

  void solve() {
    bool[int] AC;
    int penalty;
    int[int] penalties;

    foreach(trial; 0..M) {
      int p; string s; readf("%d %s\n", &p, &s);
      if (p in AC) continue;
      
      if (s == "AC") {
        AC[p] = true;
        if (p in penalties) penalty += penalties[p];
      } else {
        penalties[p]++;
      }
    }

    writefln("%s %s", AC.keys.length, penalty);
  }

  solve();
}
