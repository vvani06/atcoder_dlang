import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto size = readln.chomp.to!int;
  auto lucky = cast(byte[])readln.chomp;
  lucky[] -= '0';

  void solve() {
    int count;
    bool[byte] ava;
    foreach(a; lucky) ava[a] = true;

    foreach(x; ava.keys) foreach(y; ava.keys) foreach(z; ava.keys) {
      if (auto after_x = lucky.findSplit([x])) {
        if (auto after_y = after_x[2].findSplit([y])) {
          if (after_y[2].canFind(z)) {
            count++;
          }
        }
      }
    }
    writeln(count);
  }

  solve();
}
