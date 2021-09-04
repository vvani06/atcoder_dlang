void main() { runSolver(); }

class Graph {
  Node[] nodes;
  Path[] pathes;

  class Path {
    long identifier;
    Node from, to;
    long cost, cost2;

    this(long identifier, Node from, Node to, long cost, long cost2) {
      this.identifier = identifier;
      this.from = from;
      this.to = to;
      this.cost = cost;
      this.cost2 = cost2;
      from.add(this);
    }
  }

  class Node {
    Node[] next;
    long[] nextIdentifiers;
    Path[] pathes;
    long identifier;

    this(long identifier) {
      this.identifier = identifier;
    }

    void add(Path p) {
      pathes ~= p;
      next ~= p.to;
      nextIdentifiers ~= p.to.identifier;
    }
  }

  Node addNode(long identifier) {
    auto node = new Node(identifier);
    nodes ~= node;
    return node;
  }

  Path addPath(long identifier, long from, long to, long cost, long cost2) {
    auto path = new Path(identifier, nodes[from], nodes[to], cost, cost2);
    pathes ~= path;
    return path;
  }

  long calcCost(long time, Path path) {
    long subCalc(long time, Path path) {
      return time + path.cost + (path.cost2 / (time + 1));
    }

    const waited = max(time, path.cost2.to!real.sqrt.to!long );
    return subCalc(waited, path);
  }

  auto dijkstra(long start) {
    const nodeSize = nodes.length;
    auto costs = new long[](nodeSize);
    enum INF = 2L ^^ 60;
    costs[] = INF;
    costs[start] = 0;
    
    alias HeapValue = Tuple!(long, "cost", long, "index");
    auto heap = [HeapValue(0, start)].heapify!"a.cost > b.cost";
  
    while(!heap.empty) {
      auto v = heap.front;
      heap.removeFront;
      auto k = v.index;

      foreach(path; nodes[k].pathes) {
        const to = path.to.identifier;

        if (costs[to].chmin(calcCost(costs[k], path))) {
          heap.insert(HeapValue(costs[to], to));
        }
      }
    }

    return costs;
  }
}

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto Path = scan!long(M*4).chunks(4).array;

  auto solve() {
    enum INF = 2L ^^ 60;
    auto graph = new Graph();
    foreach(i; 0..N) graph.addNode(i);
    foreach(i, p; Path) graph.addPath(i, p[0] - 1, p[1] - 1, p[2], p[3]);
    
    auto ans = graph.dijkstra(0);
    return ans[$ - 1] == INF ? -1 : ans[$ - 1];
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time;
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
  debug { BORDER.writeln; while(true) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

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