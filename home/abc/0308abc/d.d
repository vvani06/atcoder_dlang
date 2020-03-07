import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto S = cast(char[])readln.chomp;
  auto N = readln.chomp.to!long;

  void solve() {
    bool inverted = false;
    char[200000] head;
    char[200000] tail;
    long num_head;
    long num_tail;

    foreach(_; 0..N) {
      auto query = readln.split;
      if (query[0] == "2") {
        if ((inverted && query[1] == "2") || !inverted && query[1] == "1") S = query[2] ~ S;
        if ((inverted && query[1] == "1") || !inverted && query[1] == "2") S ~= query[2]; 
        continue;
      }
      inverted ^= true;
    }
    if (inverted) {
      S.dup.reverse.writeln;
    } else {
      S.writeln;
    }
  }

  solve();
}
