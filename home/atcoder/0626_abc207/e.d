void main() { runSolver(); }

void problem() {
  auto N = scan!long;
  auto P = N.iota.map!(_ => Vector2(scan!real, scan!real)).array;
  auto Q = N.iota.map!(_ => Vector2(scan!real, scan!real)).array;

  auto solve() {
    auto ps = P.multiSort!("a.x < b.x", "a.y < b.y");
    auto pBase = ps[0];
    enum real SEIDO = 4;

    real theta = 2.0 * PI / SEIDO;
    foreach(_; 0..SEIDO) {
      Q.deb;
      auto qs = Q.multiSort!("a.x < b.x", "a.y < b.y");
      auto qBase = qs[0];
      if (N.iota.all!(i => ps[i].sub(pBase).isNear(qs[i].sub(qBase)))) return YESNO[true];

      // rotate
      // Vector2 rotate(real theta) { return Vector2(x*cos(theta) - y*sin(theta), x*sin(theta) + y*cos(theta)); }
      foreach(ref q; Q) {
        auto rotated = q.rotate(theta);
        q.x = rotated.x;
        q.y = rotated.y;
      }
    }

    return YESNO[false];
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


struct Vector2 {
  real x, y;
  this(real x, real y) { this.x = x; this.y = y; }
  Vector2 add(Vector2 other) { return Vector2(x + other.x, y + other.y ); }
  Vector2 sub(Vector2 other) { return Vector2(x - other.x, y - other.y ); }
  bool isNear(Vector2 other) { return isClose(x, other.x) && isClose(y, other.y); }
  Vector2 div(real num) { return Vector2(x / num, y / num); }

  real norm() { return x*x + y*y; }
  real length() { return norm.sqrt; }
  Vector2 rotate(real theta) { return Vector2(x*cos(theta) - y*sin(theta), x*sin(theta) + y*cos(theta)); }

  string toString() { return "%.16f %.16f".format(x, y); }
}
