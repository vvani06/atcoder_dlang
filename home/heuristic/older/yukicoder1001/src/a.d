void main() { runSolver(); }

// ----------------------------------------------

void problem() {
  auto T = scan!int;
  auto N = scan!int;
  auto M = scan!long;
  auto rnd = Xorshift(unpredictableSeed);

  auto idealStock = 61.iota.map!(a => (pow(1.05f, 2*a) / 0.16f).to!long).array;

  auto solve() {
    int preStrategy;
    foreach(week; 0..T) {
      auto money = week == 0 ? M : scan!long;
      if (money == -1) return;

      auto sold = week == 0 ? new long[](N) : scan!long(N);
      auto popularities = week == 0 ? new long[](N) : scan!long(N);
      auto stocks = week == 0 ? new long[](N) : scan!long(N);

      auto orders = new long[](N);
      long bookCost;
      foreach(i; N.iota.array.sort!((a, b) => popularities[a] > popularities[b])) {
        auto lot = idealStock[max(0, popularities[i])] * (week > 47 ? 4 : 1);
        orders[i] = max(0, lot - stocks[i]);

        if (bookCost + orders[i]*500 > money) {
          orders[i] = (money - bookCost) / 500;
        }
        bookCost += orders[i] * 500;
      }

      if (week <= 47 && money >= M && popularities.maxElement <= 55) {
        foreach_reverse(level; 1..6) {
          long cost = 500_000L * 2L^^(level - 1);
          if (money - cost >= M / 2) {
            writefln("2 %d", level);
            break;
          }
        }
        preStrategy = 2;
      } else {
        writefln("1 %(%d %)", orders);
        preStrategy = 1;
      }
      stdout.flush();
    }
  }

  outputForAtCoder(&solve);
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
