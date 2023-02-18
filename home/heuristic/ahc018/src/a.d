void main() { runSolver(); }

// ----------------------------------------------

void problem() {
  enum COST_MIN = 10;
  enum COST_MAX = 5000;
  enum POWER_MAX = 5000;
  enum N = 200;

  scan!int; // N = 200
  auto W = scan!int;
  auto K = scan!int;
  auto C = scan!int;
  auto G = scan!int(2 * (W + K)).chunks(2).array;
  
  auto solve() {
    auto costs = new int[N][N];
    foreach(i; 0..N * N) {
      costs[i / N][i % N] = 10;
    }

    auto xty = N.iota.map!(_ => new int[](0).redBlackTree).array;
    auto ytx = N.iota.map!(_ => new int[](0).redBlackTree).array;
    foreach(p; G) {
      xty[p[1]].insert(p[0]);
      ytx[p[0]].insert(p[1]);
    }

    foreach(y; 0..N) foreach(x; 0..N) {
      if (xty[y].empty && ytx[x].empty) continue;

      int sum;
      for(auto e = 1;; e *= 2) {
        auto power = min(POWER_MAX - sum, e * costs[y][x]);
        sum += power;
        writefln("%s %s %s", x, y, power);
        stdout.flush;

        const result = scan!int;
        if (result == -1 || result == 2) return;
        if (result == 1) break;
      }
    }
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
T[] divisors(T)(T n) { T[] ret; for (T i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
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
  enum BORDER = "#==================================";
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; break; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
