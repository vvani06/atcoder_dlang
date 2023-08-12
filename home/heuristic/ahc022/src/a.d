void main() { runSolver(); }

// ----------------------------------------------

struct Coord {
  int x, y;
}

struct Measurement {
  int id, sum, count;

  void add(int value) {
    sum += value;
    count++;
  }

  int avg() {
    return sum / count;
  }
}

struct Hole {
  int value, index;
  Coord coord;

  int opCmp(int other) {
    if (value == other) return 0;
    return value < other ? -1 : 1;
  }
  int opCmp(Hole other) { return opCmp(other.value); }
}

void problem() {
  auto L = scan!int;
  auto N = scan!int;
  auto S = scan!int;
  auto P = scan!int(2 * N).chunks(2).map!(c => Coord(c[1], c[0])).array;
  auto RND = Xorshift(unpredictableSeed);

  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

  enum P_EMPTY = 0;
  enum P_START = 200;
  enum P_END = 1000;

  enum MEASURE_TIMES_MAX = 10000;
  enum MEASURE_TIMES_EACH_MAX = 100;

  auto solve() {
    int[50][50] hallId; foreach(i, p; P) {
      hallId[p.y][p.x] = i.to!int + 1;
    }

    Hole[] holes; {
      int delta = (P_END - P_START) / N;
      int count;
      foreach(y; 0..L) { 
        int[] row;
        foreach(x; 0..L) {
          if (hallId[y][x] > 0) {
            auto value = P_START + count * delta;
            holes ~= Hole(value, hallId[y][x] - 1, Coord(x, y));
            row ~= value;
            count++;
          } else {
            row ~= P_EMPTY;
          }
        }

        writefln("%(%s %)", row);
        stdout.flush();
      }
    }
    auto sorted = holes.assumeSorted;
    
    auto ans = new int[](N);
    foreach(id; 0..N) {
      auto assumedIndex = new int[](N);
      foreach(t; MEASURE_TIMES_EACH_MAX.iota) {
        writefln("%(%s %)", [id, 0, 0]);
        stdout.flush();

        auto value = scan!int;
        Hole[] candidates; {
          auto lowers = sorted.lowerBound(value + 2);
          if (!lowers.empty) candidates ~= lowers.back;

          auto uppers = sorted.upperBound(value - 2);
          if (!uppers.empty) candidates ~= uppers.front;
        }
        auto best = candidates.minElement!(c => abs(c.value - value));
        assumedIndex[best.index]++;
      }

      ans[id] = assumedIndex.maxIndex.to!int;
    }

    writefln("%(%s %)", [-1, -1, -1]);
    stdout.flush();
    
    ans.each!writeln;
    stdout.flush();
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
  problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
