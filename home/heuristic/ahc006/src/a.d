void main() { problem(); }

// ----------------------------------------------

struct Point {
  long x, y;
  this(long tx, long ty) { x = tx; y = ty; }
  long distance(Point other) { return (x - other.x).abs + (y - other.y).abs; }
}
enum HOME = Point(400, 400);

struct Order {
  long id;
  Point from;
  Point to;
  this(long i, Point f, Point t) {
    id = i; from = f; to = t;
  }

  long distance() { return from.distance(to); }
}

class TRY {
  Order[] orders;
  Point cur;
  Point[] route;
  long distance;

  this() { 
    cur = HOME;
    route = [cur];
  }

  bool complete() {
    return orders.length == 50;
  }

  void addOrder(Order order) {
    orders ~= order;
  }

  void walkTo(Point to) {
    route ~= to;
    distance += to.distance(cur);
    cur = to;
  }

  long walkStraight() {
    foreach(order; orders) {
      walkTo(order.from);
      walkTo(order.to);
    }
    walkTo(HOME);
    return distance;
  }

  void clear() {
    distance = 0;
    cur = HOME;
    route = [cur];
  }

  long walkEffort() {
    alias KEY = Tuple!(Point, "p", long, "bias");
    long[Point] bias;
    Point[][Point] fromTo;
    Point[] nearGoal;
    foreach(order; orders) {
      fromTo[order.from] ~= order.to;
      bias[order.to] = 130;
      bias[order.from] = 100;
    }
    
    while(!fromTo.empty) {
      if (cur in fromTo) {
        foreach(p; fromTo[cur]) if (p != HOME) fromTo[p] ~= HOME;
      }

      long minDist = long.max / 4;
      Point to;
      foreach(p; fromTo.keys) {
        if (minDist.chmin(cur.distance(p) * bias[p])) {
          to = p;
        }
      }

      walkTo(to);
      auto nexts = fromTo[to];
      fromTo.remove(to);
      foreach(n; nexts) {
        if (n == HOME) continue;
        if (HOME.distance(n) <= 40) {
          nearGoal ~= n;
          continue;
        }

        fromTo[n] ~= HOME;
      }

      if (fromTo.empty) {
        foreach(n; nearGoal) if (n != HOME) fromTo[n] ~= HOME;
        nearGoal.length = 0;
      }
    }
    walkTo(HOME);

    return distance;
  }

  void output() {
    "%s %s".writefln(orders.length, orders.map!"a.id".array.toAnswerString);
    "%s %s".writefln(route.length, route.map!"[a.x, a.y]".array.joiner.toAnswerString);
  }
}

void problem() {
  auto allOrders = 1000.iota.map!(i => Order(i + 1, Point(scan!long, scan!long), Point(scan!long, scan!long))).array;

  auto solve() {
    auto nearSorted = allOrders;
    // auto nearSorted = allOrders.sort!"a.distance < b.distance".array;

    enum long AREA_SIZE = 20;
    Point[] areas;
    foreach(y; 0..800/AREA_SIZE + 1) foreach(x; 0..800/AREA_SIZE + 1) {
      areas ~= Point(x * AREA_SIZE, y * AREA_SIZE);
    }
    areas.sort!((a, b) => HOME.distance(a) < HOME.distance(b));

    auto fromCovered = new bool[](1000);
    auto toCovered = new bool[](1000);
    auto used = new bool[](1000);
    bool[long] baseOrders;
    area_loop:foreach(area; areas) {
      foreach(i, order; nearSorted) {
        if (area.distance(order.from) <= AREA_SIZE) fromCovered[i] = true;
        if (area.distance(order.to) <= AREA_SIZE) toCovered[i] = true;
        if (fromCovered[i] && toCovered[i]) {
          used[i] = true;
          baseOrders[i] = true;
          if (baseOrders.length == 50) break area_loop;
        }
      }
    }

    auto rnd = Xorshift(unpredictableSeed);
    auto baseKeys = baseOrders.keys;
    TRY t = new TRY();
    t.orders = baseKeys.map!(i => nearSorted[i]).array;
    long minDist = long.max / 4;
    Order[] minOrders;
    foreach(i; 0..8000) {
      t.clear;
      if (minDist.chmin(t.walkEffort)) {
        minOrders = t.orders.dup;
      }

      rnd.seed(unpredictableSeed);
      auto ri = rnd.front % 50;
      rnd.seed(unpredictableSeed);
      auto rt = rnd.front % 1000;
      while(used[rt]) {
        rnd.seed(unpredictableSeed);
        rt = rnd.front % 1000;
      }

      const removee = baseKeys[ri];
      t.orders[ri] = nearSorted[rt];
      baseKeys[ri] = rt;
      used[removee] = false;
      used[rt] = true;
    } 

    auto ans = new TRY();
    ans.orders = minOrders;
    ans.walkEffort;
    ans.output;
    stderr.writeln(10L^^8/ (1000 + ans.distance));
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

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
void runSolver() {
  enum BORDER = "#==================================";
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct CombinationRange(T) {
  private {
    int combinationSize;
    int elementSize;
    int pointer;
    int[] cursor;
    T[] elements;
    T[] current;
  }

  public:

  this(T[] t, int combinationSize) {
    this.combinationSize = combinationSize;
    this.elementSize = cast(int)t.length;
    pointer = combinationSize - 1;
    cursor = new int[combinationSize];
    current = new T[combinationSize];
    elements = t.dup;
    foreach(i; 0..combinationSize) {
      cursor[i] = i;
      current[i] = elements[i];
    }
  }

  @property T[] front() {
    return current;
  }

  void popFront() {
    if (pointer == -1) return;

    if (cursor[pointer] == elementSize + pointer - combinationSize) {
      pointer--;
      popFront();
      if (pointer < 0) return;

      pointer++;
      cursor[pointer] = cursor[pointer - 1];
      current[pointer] = elements[cursor[pointer]];
    }

    cursor[pointer]++;
    current[pointer] = elements[cursor[pointer]];
  }

  bool empty() {
    return pointer == -1;
  }
}
CombinationRange!T combinations(T)(T[] t, int size) { return CombinationRange!T(t, size); }
