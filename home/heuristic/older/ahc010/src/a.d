void main() { runSolver(); }

// ----------------------------------------------

enum GRID_SIZE = 30;
enum GRID_SEG_SIZE = GRID_SIZE * GRID_SIZE;

enum int[][] D = [
  [-1, 0],
  [0, -1],
  [1, 0],
  [0, 1]
];
int dir(int x, int y) {
  if (x == -1 && y == 0) return 0;
  if (x == 0 && y == -1) return 1;
  if (x == 1 && y == 0) return 2;
  if (x == 0 && y == 1) return 3;
  return -1;
}
int rev(int d) { return (d + 2) % 4; }

enum int[][][] T = [
  [[1, 0, -1, -1], [3, -1, -1, 0], [-1, -1, 3, 2], [-1, 2, 1, -1]],
  [[3, -1, -1, 0], [-1, -1, 3, 2], [-1, 2, 1, -1], [1, 0, -1, -1]],
  [[-1, -1, 3, 2], [-1, 2, 1, -1], [1, 0, -1, -1], [3, -1, -1, 0]],
  [[-1, 2, 1, -1], [1, 0, -1, -1], [3, -1, -1, 0], [-1, -1, 3, 2]],
  [[1, 0, 3, 2], [3, 2, 1, 0], [1, 0, 3, 2], [3, 2, 1, 0]],
  [[3, 2, 1, 0], [1, 0, 3, 2], [3, 2, 1, 0], [1, 0, 3, 2]],
  [[2, -1, 0, -1], [-1, 3, -1, 1], [2, -1, 0, -1], [-1, 3, -1, 1]],
  [[-1, 3, -1, 1], [2, -1, 0, -1], [-1, 3, -1, 1], [2, -1, 0, -1]],
];

void problem() {
  auto G = scan!string(GRID_SIZE).map!(s => s.map!(c => c.to!int - '0').array).array;

  auto solve() {
    auto ans = new int[][](GRID_SIZE, GRID_SIZE);
    auto visited = new bool[][][](GRID_SIZE, GRID_SIZE, 4);

    int searchRoute(int sx, int sy, int ex, int ey, bool[][] proh) {
      auto x = sx;
      auto y = sy;
      int r = 0;
      while(T[G[y][x]][r][2] == -1) r++;
      ans[y][x] = r;
      visited[y][x][2] = true;
      int d = 2;
      x++;
      r = 0;

      int looped;
      while(x < ex) {
        looped++;
        if (looped > 10000) break;

        while(T[G[y][x]][r][rev(d)] == -1) {
          r++;
          if (r > 3) return -1;
        }

        d = T[G[y][x]][r][rev(d)];
        x += D[d][0];
        y += D[d][1];

        if (min(x, y) < 0 || max(x, y) >= GRID_SIZE - 1 || visited[x][y][rev(d)]) {
          x -= D[d][0];
          y -= D[d][1];
          continue;
        }

        visited[y][x][rev(d)] = true;
        ans[y][x] = r;
        r = 0;
        [x, y, r].deb;
      }

      return 1;
    }

    auto proh = new bool[][](GRID_SIZE, GRID_SIZE);
    foreach(x; 5..25) foreach(y; 5..25) proh[y][x] = true;
    searchRoute(2, 2, 27, 27, proh);

    foreach(x; 0..GRID_SIZE) foreach(y; 0..GRID_SIZE) proh[y][x] ^= true;
    // searchRoute(7, 7, 22, 22, proh);

    return ans.map!(l => l.map!"(a + '0').to!char").joiner.to!string;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
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
  enum BORDER = "#==================================";
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------


struct UnionFind {
  long[] parent;

  this(long size) {
    parent.length = size;
    foreach(i; 0..size) parent[i] = i;
  }

  long root(long x) {
    if (parent[x] == x) return x;
    return parent[x] = root(parent[x]);
  }

  long unite(long x, long y) {
    long rootX = root(x);
    long rootY = root(y);

    if (rootX == rootY) return rootY;
    return parent[rootX] = rootY;
  }

  bool same(long x, long y) {
    long rootX = root(x);
    long rootY = root(y);

    return rootX == rootY;
  }
}
