void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto COND = scan!long(2*M).chunks(2).array;
  auto K = scan!long;
  auto Put = scan!long(2*K).chunks(2).array;

  void solve() {
    long ans;
    foreach(i; 0..2^^K) {
      auto balls = new long[N];
      foreach(x; 0..K) {
        auto b = i % 2;
        i /= 2;
        balls[Put[x][b] - 1]++;
      }
      long cond;
      foreach(c; COND) {
        if (balls[c[0] - 1] > 0 && balls[c[1] - 1] > 0) cond++;
      }
      ans = max(ans, cond);
    }

    ans.writeln;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
alias Mark = Tuple!(long, "y", long, "x", char, "mark");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
