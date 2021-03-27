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
  auto C = scan!long(N*N).chunks(N).array;

  auto solve() {
    auto A = new long[](N);
    auto B = new long[](N);

    foreach(i, c; C) {
      A[i] = c.minElement;
    }

    foreach(i; 0..N) {
      B[i] = N.iota.map!(n => C[n][i]).minElement;
    }

    auto X = new long[][](N, N);
    foreach(x; 0..N) foreach(y; 0..N) {
      X[y][x] = A[y] + B[x] - C[y][x];
    }

    while(true) {
      long maxX = -1;
      long maxY = -1;
      long maxValue = -1;
      long minValue = long.max;
      foreach(x; 0..N) foreach(y; 0..N) {
        minValue = minValue.min(X[y][x]);

        if (maxValue.chmax(X[y][x])) {
          maxX = x;
          maxY = y;
        }
      }

      if (minValue < 0) {
        "No".writeln;
        return;
      }

      if (maxValue == 0) break;

      auto w = X[maxY].minElement;
      auto h = N.iota.map!(n => X[n][maxX]).minElement;
      // [maxX, maxY].deb;
      // [w, h].deb;

      if (max(w, h) <= 0) {
        "No".writeln;
        return;
      }

      if (w >= h) {
        A[maxY] -= w;
        foreach(i; 0..N) X[maxY][i] -= w;
      } else {
        B[maxX] -= h;
        foreach(i; 0..N) X[i][maxX] -= h;
      }
    }
    
    "Yes".writeln;
    A.map!"a.to!string".joiner(" ").writeln;
    B.map!"a.to!string".joiner(" ").writeln;
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
