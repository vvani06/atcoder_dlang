import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto N = readln.chomp.to!ulong;
  
  ulong[string] votes;
  ulong max = 0;
  foreach(i; 0..N) {
    auto word = readln.chomp;
    if (!(word in votes)) votes[word] = 0;
    if (max < ++votes[word]) max = votes[word];
  }

  auto sorted = votes
    .keys
    .filter!(x => votes[x] == max)
    .array
    .sort()
    .array;

  foreach(word; sorted) writeln(word);
}
