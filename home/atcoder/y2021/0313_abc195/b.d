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
  auto A = scan!real;
  auto B = scan!real;
  auto W = scan!real * 1000;
  enum UNSATISFIABLE = "UNSATISFIABLE";
  
  auto solve() {
    bool isSatisfiable = false;
    foreach(k; 1..W+1) {
      if (A*k <= W && W <= B*k) {
        isSatisfiable = true;
        break;
      }
    }

    if (!isSatisfiable) {
      UNSATISFIABLE.writeln;
      return;
    }

    long low, high;
    high = floor(W / A).to!long;
    low = ceil(W / B).to!long;

    "%s %s".writefln(low, high);
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
