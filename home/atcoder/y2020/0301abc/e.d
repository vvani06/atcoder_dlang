import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto N = readln.chomp.to!int;
  auto S = readln.chomp;

  void solve() {
    ulong answer;
    bool nextKetaUp;
    auto keta = N.length;
    foreach(i; 0..keta) {
      auto num = N[$-1-i..$-i].to!(int) + (nextKetaUp ? 1 : 0);
      if (num == 10) continue;

      nextKetaUp = false;

      if (i < keta-1) {
        auto next = N[$-2-i..$-1-i].to!(int);
        if (num >= 5 && next >= 5) {
          answer += 10 - num;
          nextKetaUp = true;
          continue;
        }
      }

      if (num >= 6) {
        answer += 10 - num;
        nextKetaUp = true;
        continue;
      }

      answer += num;
    }
    if (nextKetaUp) answer++;

    writeln(answer);
  }

  solve();
}
