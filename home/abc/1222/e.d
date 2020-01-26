import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto N = readln.chomp.to!long;

  void solve() {
    if (N % 2 == 1) {
      writeln(0);
      return;
    }

    ulong countEndZero(ulong n) {
      ulong d;
      while(n%10 == 0) {
        n /= 10;
        d++;
      }
      return d;
    }

    ulong result;
    int nokori;
    for(ulong n = N; n > 0; n -= 2) {
      if (n % 50 == 0) {
        nokori = 1;
      }
      result += countEndZero(n);
      if (n % 2 == 0 && nokori == 1 && n % 50 != 0) {
        nokori = 0;
        result++;
      } 
    }

    writeln(result);
  }

  solve();
}
