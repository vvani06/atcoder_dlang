void main() { runSolver(); }

// ----------------------------------------------

void problem() {
  enum P_MIN = 1;
  enum P_MAX = 5000;
  enum H_MIN = 10;
  enum H_MAX = 5000;

  long[] sample(long overhead) {
    long[] arr;
    while(arr.sum < H_MAX) {
      arr ~= min(H_MAX - arr.sum, uniform(P_MIN + overhead, P_MAX / 6));
    }
    return arr;
  }

  long calc(long[] arr, long overhead) {
    auto acc = (0L ~ arr.cumulativeFold!"a + b".array).assumeSorted;
    long cost;
    foreach(h; H_MIN..H_MAX + 1) {
      auto t = acc.lowerBound(h).length;
      cost += (t*overhead + acc[t] - h) * (6000 - h)^^2;
    }
    return cost;
  }

  auto solve() {
    "".writeln;
    enum first = [11L, 13, 16, 20, 26, 35, 49, 70, 101, 148, 218, 323, 481, 718, 1073, 1606, 92];
    foreach(overhead; [1L, 2L, 4L, 8L, 16L, 32L, 64L, 128L]) {
      long[] bestArr = first;
      long best = calc(bestArr, overhead);
      foreach(_; 0..50_000_000) {
        auto arr = sample(overhead);
        if (best.chmin(calc(arr, overhead))) bestArr = arr;
        "\r".write;
        _.write;
      }

      "\r".write;
      writefln("[%(%s, %)], // C = %s, cost = %s", bestArr, overhead, best);
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
