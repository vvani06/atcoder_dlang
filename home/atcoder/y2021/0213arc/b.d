void main() {
  problem();
}

void problem() {
  auto B = scan!long;
  auto C = scan!long;

  struct FromTo {
    long from;
    long to;

    this(long f, long t) {
      from = min(f, t);
      to = max(f, t);
    }
  }

  auto solve() {
    FromTo[] ranges;

    ranges ~= FromTo(B - C/2, B);
    C--;
    if (C > 1) ranges ~= FromTo(C/2 - B, 1 - B);
    ranges.deb;

    B *= -1;
    ranges ~= FromTo(B - C/2, B);
    C--;
    if (C > 1) ranges ~= FromTo(C/2 - B, 1 - B);

    long left = long.min;
    long ans;
    foreach(r; ranges.sort!"a.to < b.to") {
      left = max(left, r.from);
      deb(r, " / ", left);

      ans += r.to - left + 1;
      left = r.to + 1;
    }

    // if (B < 0)
    // {
    //   long minimum = B - C / 2;
    //   ans += C; // decr until minimum & invert
    //   if (C % 2 == 0) ans--; // cannot invert minimum

    //   long maximum = -B - (C - 1) / 2;
    //   ans += (C - 1); // decr until minimum & invert
    //   if ((C - 1) % 2 == 0) ans--; // cannot invert minimum

    //   [minimum, maximum].deb;
    // }
    // else if (B > 0)
    // {
    //   long minimum = B - C / 2;
    //   ans += C; // decr until minimum & invert
    //   if (C % 2 == 0) ans--; // cannot invert minimum

    //   long maximum = -B - (C - 1) / 2;
    //   ans += (C - 1); // decr until minimum & invert
    //   if ((C - 1) % 2 == 0) ans--; // cannot invert minimum

    //   [minimum, maximum].deb;
    // }
    // else
    // {
    //   ans += C; // decr until minimum & invert
    //   if (C % 2 == 0) ans--; // cannot invert minimum
    // }

    return ans;
  }

  static if (is(ReturnType!(solve) == void)) solve(); else solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }

// -----------------------------------------------