void main() { problem(); }

// ----------------------------------------------

void problem() {
  enum long N = 20;
  const SY = scan!long;
  const SX = scan!long;
  const H = scan!string(N).map!(s => s.map!(c => c == '1').array).array;
  const W = scan!string(N - 1).map!(s => s.map!(c => c == '1').array).array;

  bool isWall(GridPoint from, GridPoint to) {
    if (from.x == to.x) {
      return W[(from.y + to.y) / 2][from.x];
    } else {
      return H[from.y][(from.x + to.x) / 2];
    }
  }

  string toAns(int[] moves) {
    string orders;
    long dir = 1;
    foreach(o; moves) {
      if (dir == (o - 1 + 4) % 4) orders ~= 'R';
      if (dir == (o + 1 + 4) % 4) orders ~= 'L';
      if (dir == (o + 2 + 4) % 4) orders ~= "RR";
      orders ~= "F";
      dir = o;
    }

    foreach_reverse(times; 2..6) {
      foreach_reverse(size; 3..17) {
        orders = orders.replaceAll(
          regex("(%s)\\1{%s}".format("[LRF]{%s}".format(size), times - 1)),
          "%s($1)".format(times)
        );
      }
    }

    string compressed;
    foreach(g; orders.group) {
      if (g[1] == 1) {
        compressed ~= g[0];
        continue;
      }

      if (g[0] == 'L' || g[0] == 'F' || g[0] == 'R') {
        compressed ~= g[1].to!string;
        compressed ~= g[0];
      } else {
        compressed ~= g[0].repeat(g[1]).to!string;
      }
    }

    return compressed;
  }

  auto solve() {
    bool[N][N] visited;
    alias Plot = Tuple!(long, "cost", GridPoint, "p", long, "dir");

    long delegate(Plot from, long dir, GridPoint to) calcCost;
    calcCost = (Plot from, long dir, GridPoint to) => from.cost + 
                       min((from.dir - dir).abs, (4 + from.dir - dir)) * 100 + 
                       (visited[to.y][to.x] ? 100 : 0);

    int[] route(GridPoint from, long fromDir, GridPoint to) {
      Plot[N][N] plots;
      foreach(ref pp; plots) foreach(ref p; pp) p.cost = int.max;
      plots[from.y][from.x].cost = 0;
      plots[from.y][from.x].cost = fromDir;

      auto queue = [Plot(0, from, fromDir)].heapify!"a.cost > b.cost";
      while(!queue.empty) {
        auto f = queue.front; queue.removeFront;
        auto p = f.p;
        if (plots[p.y][p.x].cost < f.cost) continue;

        // [[p], p.around].deb;
        foreach(long dir, pa; p.around) {
          if (pa.x < 0 || pa.y < 0 || pa.x >= N || pa.y >= N) continue;
          if (memoize!isWall(p, pa)) continue;

          const cost = calcCost(f, dir, pa);

          if (plots[pa.y][pa.x].cost.chmin(cost)) {
            plots[pa.y][pa.x].p = p;
            plots[pa.y][pa.x].dir = f.dir;
            // Plot(cost, pa, dir).deb;
            if (pa == to) break;
            queue.insert(Plot(cost, pa, dir));
          }
        }
      }

      auto tracer = to;
      int[] trace;
      while(tracer != from) {
        // tracer.deb;
        // plots[tracer.y][tracer.x].deb;
        auto t = plots[tracer.y][tracer.x].p;
        
        if (tracer.x == t.x - 1) trace ~= 0;
        if (tracer.y == t.y - 1) trace ~= 1;
        if (tracer.x == t.x + 1) trace ~= 2;
        if (tracer.y == t.y + 1) trace ~= 3;

        visited[tracer.y][tracer.x] = true;
        tracer = t;
      }
      visited[tracer.y][tracer.x] = true;
      
      return trace.reverse.array;
    }

    GridPoint[][] routes;
    {
      GridPoint[] ro;

      ro.length = 0; foreach(y; 0..N) {
        if (y % 2 == 0) foreach(x; 0..N) ro ~= GridPoint(x, y);
        if (y % 2 == 1) foreach_reverse(x; 0..N) ro ~= GridPoint(x, y);
      } routes ~= ro;
      ro.length = 0; foreach(x; 0..N) {
        if (x % 2 == 0) foreach(y; 0..N) ro ~= GridPoint(x, y);
        if (x % 2 == 1) foreach_reverse(y; 0..N) ro ~= GridPoint(x, y);
      } routes ~= ro;

      ro.length = 0; foreach(y; 0..N) {
        if (y % 2 == 1) foreach(x; 0..N) ro ~= GridPoint(x, y);
        if (y % 2 == 0) foreach_reverse(x; 0..N) ro ~= GridPoint(x, y);
      } routes ~= ro;
      ro.length = 0; foreach(x; 0..N) {
        if (x % 2 == 1) foreach(y; 0..N) ro ~= GridPoint(x, y);
        if (x % 2 == 0) foreach_reverse(y; 0..N) ro ~= GridPoint(x, y);
      } routes ~= ro;

      ro.length = 0; foreach_reverse(y; 0..N) {
        if (y % 2 == 0) foreach(x; 0..N) ro ~= GridPoint(x, y);
        if (y % 2 == 1) foreach_reverse(x; 0..N) ro ~= GridPoint(x, y);
      } routes ~= ro;
      ro.length = 0; foreach_reverse(x; 0..N) {
        if (x % 2 == 0) foreach(y; 0..N) ro ~= GridPoint(x, y);
        if (x % 2 == 1) foreach_reverse(y; 0..N) ro ~= GridPoint(x, y);
      } routes ~= ro;

      ro.length = 0; foreach_reverse(y; 0..N) {
        if (y % 2 == 1) foreach(x; 0..N) ro ~= GridPoint(x, y);
        if (y % 2 == 0) foreach_reverse(x; 0..N) ro ~= GridPoint(x, y);
      } routes ~= ro;
      ro.length = 0; foreach_reverse(x; 0..N) {
        if (x % 2 == 1) foreach(y; 0..N) ro ~= GridPoint(x, y);
        if (x % 2 == 0) foreach_reverse(y; 0..N) ro ~= GridPoint(x, y);
      } routes ~= ro;
    }

    long mi = int.max;
    string ans;

    foreach(ro; routes) {
      int[] moves;
      auto cur = GridPoint(SX, SY);
      long dir = 1;

      foreach(ref v; visited) v[] = false;
      visited[SY][SX] = true;

      foreach(to; ro) {
        if (visited[to.y][to.x]) continue;

        moves ~= route(cur, dir, to);
        dir = moves[$ - 1];
        cur = to;
      }

      auto compressed = toAns(moves);
      if (mi.chmin(compressed.length)) ans = compressed;
    }


    calcCost = (Plot from, long dir, GridPoint to) => from.cost + 
                      min((from.dir - dir).abs, (4 + from.dir - dir)) + 
                      (visited[to.y][to.x] ? 1000 : 0);

    foreach(ro; routes) {
      int[] moves;
      auto cur = GridPoint(SX, SY);
      long dir = 1;

      foreach(ref v; visited) v[] = false;
      visited[SY][SX] = true;

      foreach(to; ro) {
        if (visited[to.y][to.x]) continue;

        moves ~= route(cur, dir, to);
        dir = moves[$ - 1];
        cur = to;
      }

      auto compressed = toAns(moves);
      if (mi.chmin(compressed.length)) ans = compressed;
    }
    
    stderr.writeln(400 + (10L^^8) / (100L + ans.length));
    return ans;
  }

  solve().writeln;
}

// ----------------------------------------------

import std;
import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
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
enum YESNO = [true: "Yes", false: "No"];

alias Point = Tuple!(long, "x", long, "y");
long distance(Point a, Point b) {
  return ((a.x - b.x)^^2 + (a.y - b.y)^^2).to!real.sqrt.to!long;
}

// -----------------------------------------------


struct GridPoint {
  static enum ZERO = GridPoint(0, 0);
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