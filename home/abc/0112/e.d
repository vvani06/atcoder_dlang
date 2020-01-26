import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  long N; readf("%d %d\n", &N, &M);
  auto powers = readln.split.to!(long[]).sort!"a > b";

  debug writeln([N, M]);
  debug writeln(powers);

  void solve() {
    byte[][] used = N.iota.map!(i => new byte[N]).array;
    ulong happiness;
    long count;

    bool handshake(int x, int y) {
      auto a = x < y ? x : y;
      auto b = x < y ? y : x;
      if (used[a][b] == 2) return false;

      used[a][b]++;
      if (a == b) used[a][b]++;
      happiness += powers[a] + powers[b];
      count++;
      return true;
    }
    
    int left = 0;
    int right = 0;
    while (count < M) {
      handshake(left, right);
      handshake(left, right);
      if (++right == N) {
        right = 0; left++;
      }
    }

    happiness.writeln();
  }

  solve();
}
