void main() { runSolver(); }

void problem() {
  auto N = scan!long;
  auto XY = scan!long(2 * N).chunks(2);
  auto X = N.iota.map!(i => [i, XY[i][0]]).array.sort!"a[1] < b[1]";
  auto Y = N.iota.map!(i => [i, XY[i][1]]).array.sort!"a[1] < b[1]";

  auto solve() {
    auto ans = new long[][](0, 0);
    ans ~= [X[0][0], X[$ - 1][0], X[$ - 1][1] - X[0][1]];
    ans ~= [X[1][0], X[$ - 1][0], X[$ - 1][1] - X[1][1]];
    ans ~= [X[0][0], X[$ - 2][0], X[$ - 2][1] - X[0][1]];
    ans ~= [Y[0][0], Y[$ - 1][0], Y[$ - 1][1] - Y[0][1]];
    ans ~= [Y[1][0], Y[$ - 1][0], Y[$ - 1][1] - Y[1][1]];
    ans ~= [Y[0][0], Y[$ - 2][0], Y[$ - 2][1] - Y[0][1]];

    long i;
    long[] prev;
    foreach(a; ans.sort!"a[2] > b[2]") {
      if (prev.empty) {
        prev = a;
        i++;
        continue;
      }

      if (max(prev[0], prev[1]) == max(a[0], a[1]) && min(prev[0], prev[1]) == min(a[0], a[1])) {
        continue;
      }

      if (i == 1) {
        prev = a;
        break;
      }

      i++;
    }

    return prev[2];
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
