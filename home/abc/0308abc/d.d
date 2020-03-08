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
        if ((inverted && query[1] == "2") || !inverted && query[1] == "1") {
          tail[num_tail] = query[2][0];
          num_tail++;
        }
        if ((inverted && query[1] == "1") || !inverted && query[1] == "2") {
          head[num_head] = query[2][0];
          num_head++;
        }
        continue;
      }
      inverted ^= true;
    }
    if (inverted) {
      auto reversed_head = head[0..num_head];
      reversed_head.reverse();
      S.reverse();
      writeln( reversed_head ~ S ~ tail[0..num_tail]);
    } else {
      auto reversed_tail = tail[0..num_tail];
      reversed_tail.reverse();
      writeln(reversed_tail ~ S ~ head[0..num_head]);
    }
  }

  solve();
}
