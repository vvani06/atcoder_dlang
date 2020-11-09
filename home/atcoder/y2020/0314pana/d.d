import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  const N = readln.chomp.to!int;
  
  void solve() {
    void dfs(string s, char mx) {
      debug [s].writeln;
      if (s.length == N) {
        s.writeln;
        return;
      }

      for(char c = 'a'; c <= mx; c++) {
        dfs(s ~ c, c == mx ? cast(char)(mx + 1) : mx);
      }
    }

    dfs("", 'a');
  }

  solve();
}
