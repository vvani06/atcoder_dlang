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
  auto x0 = scan!real;
  auto y0 = scan!real;
  auto xm = scan!real;
  auto ym = scan!real;

  auto solve() {
    real cx = (x0 + xm) / 2;
    real cy = (y0 + ym) / 2;
    real sx = x0 - cx;
    real sy = y0 - cy;
    real dist = (sx*sx + sy*sy).sqrt;
    real theta = 2 * PI / N;

    // [sx, sy, dist, sin(theta), cos(theta)].deb;
    real tx = sx * cos(theta) - sy * sin(theta);
    real ty = sx * sin(theta) + sy * cos(theta);
    // [tx, ty].deb;

    real x1 = cx + tx;
    real y1 = cy + ty;
    "%.11f %.11f".writefln(x1, y1);
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