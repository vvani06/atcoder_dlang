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
  auto N = scan!long;
  alias Ball = Tuple!(long, "pos", long, "color");
  alias MinMax = Tuple!(long, "minPos", long, "maxPos");
  auto BALLS = N.iota.map!(i => Ball(scan!long, scan!long)).array;

  auto solve() {
    MinMax[long] mm;
    foreach(ball; BALLS) {
      const c = ball.color;
      if (c in mm) {
        mm[c].minPos = min(mm[c].minPos, ball.pos);
        mm[c].maxPos = max(mm[c].maxPos, ball.pos);
      } else {
        mm[c] = MinMax(ball.pos, ball.pos);
      }
    }

    long ans;
    mm[long.max] = MinMax(0, 0);
    auto keys = mm.keys.sort().array;

    long[long] dp;
    dp[0] = 0;
    foreach(long i, long c; keys) {
      auto m = mm[c];

      long[long] nextDp;
      foreach(pos; dp.keys) {
        if (pos <= m.minPos) {
          nextDp.requireMin(m.maxPos, dp[pos] + m.maxPos - pos);
        } else if (pos >= m.maxPos) {
          nextDp.requireMin(m.minPos, dp[pos] + pos - m.minPos);
        } else {
          nextDp.requireMin(m.minPos, dp[pos] + (m.maxPos - m.minPos) + (m.maxPos - pos));
          nextDp.requireMin(m.maxPos, dp[pos] + (m.maxPos - m.minPos) + (pos - m.minPos));
        }
      }
      
      dp = nextDp;
    }

    return dp[0];
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
bool requireMin(A, B)(ref A[B] assoc, B key, A value) { if (key in assoc) return assoc[key].chmin(value); else { assoc[key] = value; return true;} }
bool requireMax(A, B)(ref A[B] assoc, B key, A value) { if (key in assoc) return assoc[key].chmax(value); else { assoc[key] = value; return true;} }

// -----------------------------------------------
