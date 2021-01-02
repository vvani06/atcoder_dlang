void main() {
  problem();
}

void problem() {
  auto H = scan!long;
  auto W = scan!long;
  auto MAP = H.iota.map!(_ => cast(char[])scan).array;

  void solve() {
    auto m = GridValue!long(W, H, long.max, long.max);
    auto start = GridPoint(0L, 0L);
    auto goal = GridPoint(W - 1, H - 1);
    m[start] = 1;

    auto next = [start];
    while(next.length > 0) {
      auto points = next.dup;
      next.length = 0;

      foreach(p; points) {
        auto walk = (GridPoint q) {
          if (!m.contains(q)) return;
          if (q.of(MAP) == '.' && m[p] + 1 < m[q]) {
            m[q] = m[p] + 1;
            next ~= q;
          }
        };

        walk(p.left);
        walk(p.up);
        walk(p.right);
        walk(p.down);
      }
    }

    if (m[goal] == long.max) {
      writeln(-1);
      return;
    }

    long ans;
    foreach(s; MAP) ans += s.count('.');
    ans -= m[goal];
    ans.writeln;
  }

  solve();
}
//45min + 1WA

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.bigint, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

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

  this(GridPoint p, T nullValue, T initValue) {
    size = p;
    foreach(y; 0..size.y) g ~= new T[size.x];
    foreach(y; 0..size.y) g[y][] = initValue;
    this.nullValue = nullValue;
  }

  this(long width, long height, T nullValue, T initValue) {
    this(GridPoint(width, height), nullValue, initValue);
  }

  bool contains(GridPoint p) { return (0 <= p.y && p.y < size.y && 0 <= p.x && p.x < size.x); }
  T at(GridPoint p) { return contains(p) ? g[p.y][p.x] : nullValue; }
  T opIndex(GridPoint p) { return at(p); }
  T setAt(GridPoint p, T value) { return contains(p) ? g[p.y][p.x] = value : nullValue; }
  T opIndexAssign(T value, GridPoint p) { return setAt(p, value); }
}
