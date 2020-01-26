import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto N = readln.chomp.to!(ulong);

  void solve() {
    ulong answer;
    ulong keta = 1;
    ulong[ulong] ht_set;
    foreach(i; 11..100) ht_set[i] = 0;

    foreach(i; 1..N+1) {
      auto tail = i % 10;
      if (tail == 0) {
        keta = i.to!(string).length;
        continue;
      }

      auto head = i / 10.pow(keta - 1);
      auto htkey = head*10 + tail;

      if (head == tail) {
        answer += ht_set[htkey] * 2 + 1;
      } else {
        auto inverted_key = tail*10 + head;
        answer += ht_set[inverted_key] * 2;
      }
      
      ht_set[htkey]++;

      auto inverted = i % 10.pow(keta - 1);
      inverted -= inverted % 10;
      inverted += head + tail * 10.pow(keta - 1);
      if (inverted <= i) {
      }
    }

    answer.writeln();
    // ht_set.writeln();
  }

  solve();
}
