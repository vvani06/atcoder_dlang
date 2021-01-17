void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto K = scan!long;
  auto A = scan!long(N);

  void solve() {
    long[] balls = new long[N];
    foreach(a; A) if (balls[a] < K) balls[a]++;

    long ans;
    long prev = balls[0];
    foreach(i; 0..N) {
      [i, prev, balls[i]].deb;
      balls[i] = min(prev, balls[i]);

      ans += (prev - balls[i]) * i;

      if (balls[i] == 0) break;
      prev = balls[i];
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
alias Card = Tuple!(long, "identifier", long, "A", long, "B");
alias Color = Tuple!(long, "identifier", long, "rarity", Card[], "others", bool, "used");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
