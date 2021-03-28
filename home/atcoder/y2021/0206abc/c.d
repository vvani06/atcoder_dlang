void main() {
  problem();
}

void problem() {
  auto H = scan!long;
  auto W = scan!long;
  auto MAP = H.iota.map!(_ => scan.map!(c => c == '#').array).array;

  void solve() {
    auto g = GridValue!long(W + 1, H + 1, 0);
    long ans;

    foreach(x; 1..W-1) {
      foreach(y; 1..H-1) {
        auto p = GridPoint(x, y);
        if (!p.of(MAP)) continue;

        auto t = [[p.left, p.up, p.leftUp]];
        t ~= [p.up, p.right, p.rightUp];
        t ~= [p.right, p.down, p.rightDown];
        t ~= [p.down, p.left, p.leftDown];

        foreach(r; t) {
          if (!r[0].of(MAP) && !r[1].of(MAP)) {
            ans++;
          }
          if (r[0].of(MAP) && r[1].of(MAP) && !r[2].of(MAP)) {
            ans++;
          }
        }
      }
    }

    ans.writeln;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
alias Mark = Tuple!(long, "y", long, "x", char, "mark");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------


struct GridPoint {
  static enum ZERO = GridPoint(0, 0);
  long x, y;
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
  inout T of(T)(inout ref T[][] grid) { return grid[y][x]; }
}

struct GridValue(T) {
  T nullValue;
  GridPoint size;
  T[][] g;

  this(GridPoint p, T nullValue) {
    size = p;
    foreach(y; 0..size.y) g ~= new T[size.x];
    this.nullValue = nullValue;
  }

  this(long width, long height, T nullValue) {
    this(GridPoint(width, height), nullValue);
  }

  bool contains(GridPoint p) { return (0 <= p.y && p.y < size.y && 0 <= p.x && p.x < size.x); }
  T at(GridPoint p) { return contains(p) ? g[p.y][p.x] : nullValue; }
  T opIndex(GridPoint p) { return at(p); }
  T setAt(GridPoint p, T value) { return contains(p) ? g[p.y][p.x] = value : nullValue; }
  T opIndexAssign(T value, GridPoint p) { return setAt(p, value); }
}
