void main() { runSolver(); }

// ----------------------------------------------

struct Polyomino {
  int id;
  long cost;
  int h, w;
  int[][] shape;
  int fills;
  int canLoop;

  static Polyomino fromInput(int id) {
    auto n = scan!int;
    auto m = scan!int;
    auto c = scan!long;
    auto g = scan!string(n);

    auto p = Polyomino();
    p.id = id;
    p.h = n;
    p.w = m;
    p.cost = c;
    p.shape = g.map!(l => m.iota.filter!(x => l[x] == '#').array).array;
    foreach(s; p.shape) p.fills += s.length;

    p.canLoop = p.shape.any!(l => l.length == p.w);
    p.canLoop &= p.w.iota.any!(x => p.shape.all!(l => l.canFind(x)));
    p.canLoop.deb;
    
    return p;
  }
}

alias Action = Tuple!(Polyomino, "p", int, "x", int, "y");

void problem() {
  auto N = scan!int;
  auto K = scan!int;
  auto B = scan!int;
  auto GOALS = scan!int(K * 2).chunks(2);
  auto POLYOMINOS = B.iota.map!(i => Polyomino.fromInput(i + 1)).array;

  auto solve() {
    bool[GridPoint] goals;
    foreach(g; GOALS) goals[GridPoint(g[1], g[0])] = true;
    auto grid = new bool[][](N, N);
    auto rest = K;
    Action[] ans;
    
    auto sortedPolyminos = POLYOMINOS[1..$].dup.multiSort!("a.canLoop > b.canLoop", "a.w*a.h > b.w*b.h", "a.fills > b.fills");
    auto largest = sortedPolyminos[0];
    for(int x = 0; x + largest.w < N; x += largest.w) {
      for(int y = 0; y + largest.h < N; y += largest.h) {
        ans ~= Action(largest, x, y);
        foreach(ty, xs; largest.shape) {
          foreach(tx; xs) grid[y + ty][x + tx] = true;
        }
      }
    }

    foreach(g; GOALS) goals[GridPoint(g[1], g[0])] = true;
    alias HeapValue = Tuple!(GridPoint, "p", long, "cost");
    const fillCost = POLYOMINOS[0].cost;
    const rect = GridPoint(N, N);
    enum DIRS = [[1, 0], [0, 1], [0, -1], [-1, 0]];

    foreach(start; goals.keys) {
      auto from = new byte[][](N, N);
      auto costs = new long[][](N, N);
      foreach(ref cs; costs) cs[] = int.max;
      SEARCH:for(auto q = [HeapValue(start, 0)].heapify!"a.cost > b.cost"; !q.empty;) {
        auto hv = q.front; q.removeFront;
        auto p = hv.p;
        if (hv.cost >= costs[p.y][p.x]) continue;
        costs[p.y][p.x] = hv.cost;

        static foreach(di, dir; DIRS) {{
          const x = dir[0] + p.x;
          const y = dir[1] + p.y;
          if (x < 0 || x >= N) continue SEARCH;
          if (y < 0 || y >= N) continue SEARCH;

          const c = hv.cost + (grid[y][x] ? 0 : fillCost);
          if (c < costs[y][x]) {
            from[y][x] = 4 - di;
            q.insert(HeapValue(GridPoint(x, y), c));
          }
        }}
      }

      foreach(g; GOALS) {
        int x = g[1];
        int y = g[0];
        if (!grid[y][x]) {
          grid[y][x] = true;
          ans ~= Action(POLYOMINOS[0], x, y);
        }
        while(from[y][x] != 0) {
          if (!grid[y][x]) {
            grid[y][x] = true;
            ans ~= Action(POLYOMINOS[0], x, y);
          }
          const d = from[y][x] - 1;
          x += DIRS[d][0];
          y += DIRS[d][1];
        }
      }
    }

    ans.length.writeln;
    foreach(a; ans) "%s %s %s".writefln(a.p.id, a.y, a.x);
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop;
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
struct ModInt(uint MD) if (MD < int.max) {ulong v;this(string v) {this(v.to!long);}this(int v) {this(long(v));}this(long v) {this.v = (v%MD+MD)%MD;}void opAssign(long t) {v = (t%MD+MD)%MD;}static auto normS(ulong x) {return (x<MD)?x:x-MD;}static auto make(ulong x) {ModInt m; m.v = x; return m;}auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r.v));}auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r.v));}auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r.v%MD).to!ulong);}auto opBinary(string op:"^^", T)(T r) const {long x=v;long y=1;while(r){if(r%2==1)y=(y*x)%MD;x=x^^2%MD;r/=2;} return make(y);}auto opBinary(string op:"/")(ModInt r) const {return this*memoize!inv(r);}static ModInt inv(ModInt x) {return x^^(MD-2);}string toString() const {return v.to!string;}auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}}
alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);
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
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct GridPoint {
  static enum ZERO = GridPoint(0, 0);
  int x, y;
 
  static GridPoint reversed(int y, int x) {
    return GridPoint(x, y);
  }
 
  this(int x, int y) {
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
  inout GridPoint[] around() { return [left(), up(), right(), down()]; }
  inout GridPoint[] around(GridPoint max) { GridPoint[] ret; if (x > 0) ret ~= left; if(x < max.x-1) ret ~= right; if(y > 0) ret ~= up; if(y < max.y-1) ret ~= down; return ret; }
  inout T of(T)(inout ref T[][] grid) { return grid[y][x]; }
}
 
struct GridValue(T) {
  T nullValue;
  GridPoint size;
  T[][] g;
 
  this(GridPoint p, T nullValue) {
    size = p;
    foreach(y; 0..size.y) {
      g ~= new T[size.x];
      g[$-1][] = nullValue;
    }
    this.nullValue = nullValue;
  }
 
  this(long width, long height, T nullValue) {
    this(GridPoint(width, height), nullValue);
  }
 
  this(T[][] values, T nullValue) {
    this.nullValue = nullValue;
    size = GridPoint(values[0].length, values.length);
    g = values;
  }
 
  bool contains(GridPoint p) { return (0 <= p.y && p.y < size.y && 0 <= p.x && p.x < size.x); }
  T at(GridPoint p) { return contains(p) ? g[p.y][p.x] : nullValue; }
  T opIndex(GridPoint p) { return at(p); }
  T setAt(GridPoint p, T value) { return contains(p) ? g[p.y][p.x] = value : nullValue; }
  T opIndexAssign(T value, GridPoint p) { return setAt(p, value); }
}