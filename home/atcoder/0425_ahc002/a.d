void main() {
  debug {
    "==================================".writeln;
    while(true) {
      auto bench =  benchmark!problem(1);
      "<<< Process time: %s >>>".writefln(bench[0]);
      "==================================".writeln;
    }
  } else {
    problem();
  }
}

void problem() {
  auto SX = scan!long;
  auto SY = scan!long;
  auto T = scan!long(2500).chunks(50).array;
  auto P = scan!long(2500).chunks(50).array;

  auto solve() {
    alias Evaluate = Tuple!(GridPoint, "p", long, "score");
    auto visited = new bool[](2501);
    auto cur = GridPoint(SY, SX);
    visited[cur.of(T)] = true;

    long score = P[SY][SX];
    string ans;

    long maxScore;
    string maxAns;

    long[][] resetCounter;

    foreach(_; 0..10^^6) {
      bool reset;
      foreach(ref r; resetCounter) {
        if (r[0]-- == 0) {
          reset = true;
          visited[r[1]] = false;
        }
      }
      if (reset) resetCounter = resetCounter.filter!(r => r[0] > 0).array;      

      auto around = cur.around;
      auto evaluated = around.filter!(c => !visited[c.of(T)]).map!(c => Evaluate(c, c.of(P))).array;
      if (evaluated.empty) {
        if (ans.empty) continue;

        score -= cur.of(P);
        resetCounter ~= [6, cur.of(T)];
        auto last = ans[$ - 1];
        ans = ans[0..$-1];
        if (last == 'L') cur = cur.right;
        if (last == 'R') cur = cur.left;
        if (last == 'U') cur = cur.down;
        if (last == 'D') cur = cur.up;
      }
      
      foreach(e; evaluated.sort!((a, b) => a.score > b.score)) {
        ans ~= 
          cur.x < e.p.x ? 'R' :
          cur.x > e.p.x ? 'L' :
          cur.y > e.p.y ? 'U' : 'D';

        cur = e.p;
        score += e.score;
        if (maxScore < score) {
          maxScore = score;
          maxAns = ans;
        }
        visited[cur.of(T)] = true;
        break;
      }
    }

    maxScore.deb;
    return maxAns;
  }

  static if (is(ReturnType!(solve) == void)) solve(); else solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
struct GridPoint {
  static enum ZERO = GridPoint(0, 0);
  static rectX = 50 - 1;
  static rectY = 50 - 1;
  long x, y;
 
  static GridPoint reversed(long y, long x) {
    return GridPoint(x, y);
  }
 
  this(long x, long y) {
    this.x = x;
    this.y = y;
  }
 
  inout GridPoint left() { return GridPoint(x - 1, y); }
  inout GridPoint right() { return GridPoint(x + 1, y); }
  inout GridPoint up() { return GridPoint(x, y - 1); }
  inout GridPoint down() { return GridPoint(x, y + 1); }
  inout GridPoint leftUp() { return GridPoint(x - 1, y - 1); }
  inout GridPoint leftDown() { return GridPoint(x - 1, y + 1); }
  inout GridPoint rightUp() { return GridPoint(x + 1, y - 1); }
  inout GridPoint rightDown() { return GridPoint(x + 1, y + 1); }
  inout GridPoint[] around() {
    auto ret = new GridPoint[](0);
    if (x > 0) ret ~= left();
    if (x < rectX) ret ~= right();
    if (y > 0) ret ~= up();
    if (y < rectY) ret ~= down();
    return ret;
  }
  inout T of(T)(inout ref T[][] grid) { return grid[y][x]; }
}