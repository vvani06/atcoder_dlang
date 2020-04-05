import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto S = cast(char[])readln.chomp;
  auto N = readln.chomp.to!int;

  void solve() {
    bool inverted = false;
    char[200000] head;
    char[200000] tail;
    int num_head;
    int num_tail;

    foreach(_; 0..N) {
      byte queryType; readf(" %d", &queryType);

      if (queryType == 1) {
        inverted ^= true;
        continue;
      }

      byte forHead;
      char toAppend;
      readf(" %d %c\n", &forHead, &toAppend);

      if ((forHead == 1) ^ inverted) {
          tail[num_tail++] = toAppend;
      } else {
          head[num_head++] = toAppend;
      }
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
