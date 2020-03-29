import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

alias Robot = Tuple!(long, "x", long, "end", long, "makikomi");

void main() {
  auto N = readln.chomp.to!(long);
  Robot[] robots = new Robot[N];
  foreach(i; 0..N) {
    auto line = readln.split.to!(long[]);
    robots[i].x = line[0];
    robots[i].end = line[0] + line[1];
  }
  robots = robots.sort!((a, b) => a.x < b.x).array;
  ulong.max.writeln;

  void solve() {
    for(long i = N-1; i >= 0; i--) {
      foreach(j; i+1..N) {
        if (robots[j].x >= robots[i].end) break;
        robots[i].makikomi++;
      }
    }
    robots.writeln;
  }

  solve();
}
