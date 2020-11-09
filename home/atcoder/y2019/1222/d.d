import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto size = readln.chomp.to!int;
  auto numbers = readln.split.to!(int[]);

  void solve() {
    int next = 1;
    int break_count;
    foreach(n; numbers) {
      if (next != n) {
        break_count++;
        continue;
      }
      next++;
    }

    writeln(next == 1 ? -1 : break_count);
  }

  solve();
}
