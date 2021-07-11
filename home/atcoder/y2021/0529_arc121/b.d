void main() { runSolver(); }

void problem() {
  auto N = scan!long;
  enum ColorMap = ['R': 0, 'G': 1, 'B': 2];
  alias Dog = Tuple!(long, "cutiness", long, "color");
  auto DOGS = (2 * N).iota.map!(i => Dog(scan!long, ColorMap[scan[0]])).array;

  auto solve() {
    auto perColor = new Dog[][](3, 0);
    foreach(dog; DOGS.sort!"a.cutiness < b.cutiness") {
      perColor[dog.color] ~= dog;
    }

    if (perColor.all!(c => c.length % 2 == 0)) return 0;

    Dog[] even;
    Dog[][] odds;

    foreach(i; 0..3) if (perColor[i].length % 2 == 1) odds ~= perColor[i]; else even = perColor[i];
    long ans = long.max;

    foreach(o1; odds[0]) {
      auto lowers = odds[1].assumeSorted!"a.cutiness < b.cutiness".lowerBound(o1);
      const o2l = max(0, lowers.length.signed - 1);
      auto o2c = odds[1][o2l..min(o2l + 2, odds[1].length)];
      ans = ans.min(o2c.map!(o2 => (o2.cutiness - o1.cutiness).abs).minElement);
    }

    if (!even.empty) {
      long ans2a = long.max;
      foreach(o1; odds[0]) {
        auto lowers = even.assumeSorted!"a.cutiness < b.cutiness".lowerBound(o1);
        const el = max(0, lowers.length.signed - 1);
        auto ec = even[el..min(el + 2, even.length)];
        ans2a = ans2a.min(ec.map!(e => (e.cutiness - o1.cutiness).abs).minElement);
      }
      long ans2b = long.max;
      foreach(o2; odds[1]) {
        auto lowers = even.assumeSorted!"a.cutiness < b.cutiness".lowerBound(o2);
        const el = max(0, lowers.length.signed - 1);
        auto ec = even[el..min(el + 2, even.length)];
        ans2b = ans2b.min(ec.map!(e => (e.cutiness - o2.cutiness).abs).minElement);
      }
      ans = ans.min(ans2a + ans2b);
    }

    return ans;
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
