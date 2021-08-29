void main() { runSolver(); }

void problem() {
  auto N = scan!long;
  auto P = scan!long(N - 1);
  auto Q = scan!long;
  auto Queries = scan!long(2 * Q).chunks(2);

  auto solve() {
    long[][] graph = new long[][](N, 0);
    foreach(i, p; P) {
      graph[p - 1] ~= i + 1;
    }

    long depth, index;
    auto journeyIn = new long[](N);
    auto journeyOut = new long[](N);
    auto IndiciesPerDepth = new long[][](N, 0);
    void dfs(long p, long from) {
      journeyIn[p] = index++;
      IndiciesPerDepth[depth] ~= index;
      foreach(n; graph[p]) {
        if (n == from) continue;

        depth++;
        dfs(n, p);
        depth--;
      }
      journeyOut[p] = index;
    }

    dfs(0, -1);
    IndiciesPerDepth.deb;

    foreach(q; Queries) {
      const via = q[0] - 1;
      const d = q[1];
      IndiciesPerDepth[d].assumeSorted.upperBound(journeyIn[via]).lowerBound(journeyOut[via] + 1).length.writeln;
    }
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
