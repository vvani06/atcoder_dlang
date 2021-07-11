void main() { runSolver(); }

void problem() {
  auto N = scan!long;
  auto S = scan!string(N);

  auto solve() {
    long[string] nodes;
    foreach(s; S) {
      if (!(s[0..3] in nodes)) {
        nodes[s[0..3]] = nodes.length;
      } 
      if (!(s[$-3..$] in nodes)) {
        nodes[s[$-3..$]] = nodes.length;
      }
    }
    long L = nodes.length;
    auto pathes = new long[][](L, 0);
    auto revPathes = new long[][](L, 0);
    foreach(s; S) {
      const from = nodes[s[0..3]];
      const to = nodes[s[$-3..$]];
      pathes[from] ~= to;
      revPathes[to] ~= from;
    }

    nodes.deb;
    pathes.deb;
    auto ans = new int[](L);
    long[] goals;
    foreach(i; 0..L) {
      if (pathes[i].empty) {
        goals ~= i;
        ans[i] = -1;
      }
    }
    while(!goals.empty) {
      bool[long] nexts;
      foreach(g; goals) {
        foreach(rev; revPathes[g]) {
          ans[rev] = 1;
          foreach(n; revPathes[rev]) {
            if (ans[n] == 0) nexts[n] = true;
          }
        }
      }
      goals.length = 0;
      foreach(n; nexts.keys) {
        if (ans[n] != 0) continue;

        if (pathes[n].all!(x => ans[x] == 1)) {
          ans[n] = -1;
          goals ~= n;
        }
      }
    }

    enum messages = [
      -1: "Takahashi",
      0: "Draw",
      1: "Aoki",
    ];
    foreach(s; S) {
      auto x = nodes[s[$-3..$]];
      messages[ans[x]].writeln;
    }
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop;
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
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(true) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
