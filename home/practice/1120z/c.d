void main() {
  problem();
}

void problem() {
  auto H = scan!long;
  auto W = scan!long;
  auto Grid1 = H.iota.map!(_ => scan!long(W)).array;
  auto Grid2 = H.iota.map!(_ => scan!long(W)).array;

  void solve() {
    auto g1 = GridValue!long(W, H, 0, Grid1);
    auto g2 = GridValue!long(W, H, 0, Grid2);

    long cost;
    foreach(y; 0..H) {
      foreach(x; 0..W) {
        const p = GridPoint(x, y);
        if(g1.at(p) == g2.at(p)) continue;

        cost++;

        if(g1.at(p) != g1.at(p.right) && g1.at(p.right) != g2.at(p.right)) {
          g1[p] = g1[p] ^ 1;
          g1[p.right] = g1[p.right] ^ 1;
          deb("W", p);
          continue;
        }

        if(g1.at(p) != g1.at(p.down) && g1.at(p.down) != g2.at(p.down)) {
          g1[p] = g1[p] ^ 1;
          g1[p.down] = g1[p.down] ^ 1;
          deb("H", p);
          continue;
        }

        deb("S", p);
        g1[p] = g1[p] ^ 1;
      }
    }

    cost.writeln;
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

  this(GridPoint p, T nullValue, T[][] values = null) {
    size = p;
    this.nullValue = nullValue;
    this.g = values.dup;
    if (values == null || values.empty) {
      foreach(y; 0..size.y) g ~= new T[size.x];
    }
  }

  this(long width, long height, T nullValue, T[][] values = null) {
    this(GridPoint(width, height), nullValue, values);
  }

  bool contains(GridPoint p) { return (0 <= p.y && p.y < size.y && 0 <= p.x && p.x < size.x); }
  T at(GridPoint p) { return contains(p) ? g[p.y][p.x] : nullValue; }
  T opIndex(GridPoint p) { return at(p); }
  T setAt(GridPoint p, T value) { return contains(p) ? g[p.y][p.x] = value : nullValue; }
  T opIndexAssign(T value, GridPoint p) { return setAt(p, value); }
}
