void main() { runSolver(); }

// ----------------------------------------------

void problem() {
  auto L = scan!int;
  auto N = scan!int;
  auto S = scan!int;

  struct Coord {
    int x, y;
  }

  struct Hole {
    int id, x, y;

    int dist(Coord c) {
      int ret = int.max;
      foreach(dx, dy; zip([-L, 0, L], [-L, 0, L])) {
        ret = min(ret, abs(c.x - x + dx) + abs(c.y - y + dy));
      }
      return ret;
    }

    Coord to(Coord c) {
      int minDist = int.max;
      Coord ret;
      foreach(dx, dy; zip([-L, 0, L], [-L, 0, L])) {
        if (minDist.chmin(abs(c.x - x + dx) + abs(c.y - y + dy))) {
          ret = Coord(c.x - x + dx, c.y - y + dy);
        }
      }
      return ret;
    }
  }

  auto P = scan!int(2 * N).chunks(2).map!(c => Coord(c[1], c[0])).array;
  auto RND = Xorshift(unpredictableSeed);
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

  enum P_EMPTY = -1;
  enum MEASURE_TIMES_MAX = 10000;

  auto solve() {
    auto heatmap = new int[][](L, L);
    auto holes = N.iota.map!(i => Hole(i, P[i].x, P[i].y)).array;

    const maximumHeat = min(1000, S * 10);
    const measurementThreashold = (maximumHeat * 2) / 3;

    auto maxCoord = Coord(0, 0); {
      int bestDistancesSum = int.max;
      foreach(y; 0..L) foreach(x; 0..L) {
        auto c = Coord(x, y);
        if (bestDistancesSum.chmin(holes.map!(p => p.dist(c)).sum)) maxCoord = c;
      }
    }
    holes.sort!((a, b) => a.dist(maxCoord) < b.dist(maxCoord));
    heatmap[maxCoord.y][maxCoord.x] = maximumHeat;
    foreach(y; 0..L) {
      writefln("%(%s %)", heatmap[y]);
      stdout.flush();
    }

    // Measurement 
    auto ans = new int[](N);

    auto rest = N.iota.redBlackTree;
    auto assumed = new bool[](N);
    auto measurementTimes = S >= 121 ? 2 : 1;
    foreach(hole; holes[0..$ - 1]) {
      foreach(i; rest) {
        auto to = hole.to(maxCoord);

        int measured; 
        foreach(_; 0..measurementTimes) {
          writefln("%(%s %)", [i, to.y, to.x]);
          stdout.flush();
          measured += scan!int;
        }
          
        if (measured / measurementTimes >= measurementThreashold) {
          ans[i] = hole.id;
          rest.removeKey(i);
          deb([i], [measured], hole);
          break;
        }
      }
    }
    rest.deb;
    ans[rest.front] = holes[$ - 1].id;

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
