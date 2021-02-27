void main() {
  problem();
}

void problem() {
  alias Term = Tuple!(long, "freq", long, "good");
  long inGood(Term term, long t) {
    return term.freq - (t % term.freq) < term.good ? t : 0;
  }

  auto solve(Term t, Term s) {
    if (s.freq > t.freq * 2) {
      t.freq *= s.freq / t.freq;
    }

    if (s.freq >= t.freq && s.freq % t.freq == 0) {
      auto ht = t;
      ht.freq /= 2;
      if (inGood(s, ht.freq - ht.good) * inGood(ht, s.freq - s.good) == 0) return -1;
    }


    auto ht = t;
    ht.freq /= 2;
    if (inGood(s, ht.freq - ht.good)) return ht.freq - ht.good;
    if (inGood(ht, s.freq - s.good)) return s.freq - s.good;


    long ans;
    return ans;
  }

  auto T = scan!long;
  foreach(_; 0..T) {
    auto Q = scan!long(4);
    auto ans = solve(Term(2*(Q[0] + Q[1]), Q[1]), Term(Q[2] + Q[3], Q[3]));
    
    if (ans == -1) "infinity".writeln; else ans.writeln;
  }
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint;
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
