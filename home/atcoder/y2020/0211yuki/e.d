import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
import std.bigint, std.functional;

void main() {
  auto Ni = readln.chomp;
  auto K = readln.chomp.to!(ulong);
  auto N = BigInt(Ni);
  auto Ns = Ni.length;
  ulong ans;

  char[] keta_base;
  foreach(i; 0..Ns-1) keta_base ~= "0";

  void solve1() {
    foreach(i; 1..Ns) ans += 9;
    foreach(i; 1..10) {
      if (BigInt(i.to!(char[]) ~ keta_base) <= N) ans++;
    }
  }

  void solve2() {
    foreach(i; 1..Ns) ans += (i-1)*81;
    foreach(i; 1..10) {
      foreach(k; 1..Ns) {
        char[] num = i.to!(char[]) ~ keta_base;
        if (BigInt(num) > N) break;

        foreach(o; 1..10) {
          num[k] = cast(char)(o + '0');
          if (BigInt(num) <= N) {
            ans++;
          }
        }
      }
    }
  }

  void solve3() {
    ulong sigma;
    foreach(i; 3..Ns) {
      sigma += i - 2;
      ans += sigma*729;
    }
    foreach(h; 1..10) {
      foreach(k; 1..Ns-1) {
      foreach(l; k+1..Ns) {
        char[] num = h.to!(char[]) ~ keta_base;
        foreach(i; 1..10) {
          for(int o = 9; o > 0; o--) {
            num[k] = cast(char)(i + '0');
            num[l] = cast(char)(o + '0');
            if (BigInt(num) <= N) {
              ans += o;
              break;
            }
          }
        }
      }
      }
    }
  }

  void solve() {
    if (K == 1) solve1();
    if (K == 2) solve2();
    if (K == 3) solve3();
    writeln(ans);
  }

  solve();
}
