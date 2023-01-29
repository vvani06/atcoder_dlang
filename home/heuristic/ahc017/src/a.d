void main() { runSolver(); }

// ----------------------------------------------

struct Edge {
  int id, u, v; long w;

  inout int opCmp(Edge other) {
    if (w < other.w) return 1;
    if (w > other.w) return -1;
    if (u < other.u) return 1;
    if (u > other.u) return -1;
    if (v < other.v) return 1;
    if (v > other.v) return -1;
    return 0;
  }
}

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto D = scan!int;
  auto K = scan!int;
  auto E = M.iota.map!(i => Edge(i, scan!int - 1, scan!int - 1, scan!long)).array;
  auto P = scan!long(2 * N).chunks(2).array;
  
  auto solve() {
    auto city = new Edge[][](N, 0);
    foreach(e; E) {
      city[e.u] ~= Edge(e.id, e.u, e.v, e.w);
      city[e.v] ~= Edge(e.id, e.v, e.u, e.w);
    }

    auto et = E.redBlackTree;
    int[][] schedule;

    while(!et.empty) {
      auto used = new bool[](N);
      int[] targets;
      foreach(e; et.array) {
        if (used[e.u] || used[e.v]) continue;

        used[e.u] = used[e.v] = true;
        targets ~= e.id;
        et.removeKey(e);
      }

      schedule ~= targets;
    }



    auto ans = new int[](M);
    const perDay = min(K, (M + D - 1) / D);
    int day = 1, count = 0;
    foreach(s; schedule) {
      foreach(r; s) {
        ans[r] = day;
        if (++count == perDay) {
          day++; count = 0;
        }
      }
      // day++; count = 0;
    }

    // schedule.map!"a.length".deb;
    ans.toAnswerString.writeln;
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
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
