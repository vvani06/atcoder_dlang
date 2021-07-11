void main() { runSolver(); }

void problem() {
  auto H = scan!long;
  auto W = scan!long;
  auto MAP = scan!string(H).map!(s => s.map!(c => c == '+' ? 1 : -1).array).array;

  auto solve() {
    // score of Takashi - Aoki
    auto dp = new long[][](H, W);
    dp[H - 1][W - 1] = 0;

    foreach_reverse(y; 0..H) foreach_reverse(x; 0..W) {
      const isT = (x + y) % 2 == 0;

      long[] score;
      if (isT) {
        if (x < W - 1) score ~= dp[y][x + 1] + MAP[y][x + 1];
        if (y < H - 1) score ~= dp[y + 1][x] + MAP[y + 1][x];
      } else {
        if (x < W - 1) score ~= dp[y][x + 1] - MAP[y][x + 1];
        if (y < H - 1) score ~= dp[y + 1][x] - MAP[y + 1][x];
      }

      if (!score.empty) dp[y][x] = isT ? score.maxElement : score.minElement;
    }

    string ans(long spread) {
      if (spread == 0) return "Draw";
      return spread > 0 ? "Takahashi" : "Aoki";
    }

    dp.deb;
    return ans(dp[0][0]);
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time;
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").to!string; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == float) || is(T == double) || is(T == real)) "%.16f".writefln(fn());
  else static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
  else static if (isInputRange!T) {
    static if (!is(string == ElementType!T) && isInputRange!(ElementType!T)) foreach(r; fn()) r.toAnswerString.writeln;
    else foreach(r; fn()) r.writeln;
  }
  else fn().writeln;
}
void runSolver() {
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(true) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
