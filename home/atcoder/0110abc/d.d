void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto C = scan!long;
  auto S = N.iota.map!(x => UseService(scan!long, scan!long + 1, scan!long)).array;

  void solve() {
    long[long] feeUp, feeDown;
    foreach(s; S) {
      feeUp.require(s.start, 0);
      feeDown.require(s.start, 0);
      feeUp.require(s.end, 0);
      feeDown.require(s.end, 0);
      feeDown[s.end] += s.fee;
      feeUp[s.start] += s.fee;
    }

    long ans;
    long fee;
    auto days = feeUp.keys.sort().array;
    long prev = days[0];
    foreach(k; days) {
      ans += min(fee, C) * (k - prev);
      fee += feeUp[k];
      fee -= feeDown[k];
      [prev, k, fee].deb;
      prev = k;
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
alias UseService = Tuple!(long, "start", long, "end", long, "fee");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
