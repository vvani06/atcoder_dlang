void main() {
  debug {
    "==================================".writeln;
    while(true) {
      auto bench =  benchmark!problem(1);
      "<<< Process time: %s >>>".writefln(bench[0]);
      "==================================".writeln;
    }
  } else {
    problem();
  }
}

void problem() {
  enum long MOD = 998244353;
  auto N = scan!long;
  auto M = scan!long;

  auto solve() {
    long[] dp0;
    long MM = M;
    foreach(b; 0..20) {
      dp0 ~= (MM - MM/2);
      MM /= 2;
      if (MM == 0) break;
    }
    
    const L = dp0.length;
    auto dp = new long[][](N, L);
    dp[0] = dp0.reverse;
    auto rev = dp[0].dup;

    dp[0].deb;
    rev.deb;
    foreach(i; 1..N) {
      foreach(s; 0..L) {
        foreach(t; s..L) {
          [s, t, rev[t - s]].deb;
          auto x = (dp[i - 1][s] * (rev[t - s])) % MOD;
          dp[i][t] = (dp[i][t] + x) % MOD;
        }
      }
    }

    dp.deb;

    long ans;
    foreach(d; dp[$-1]) {
      ans = (ans + d) % MOD;
    }

    return ans;
  }

  static if (is(ReturnType!(solve) == void)) solve(); else solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
