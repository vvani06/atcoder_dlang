void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int M = scan!int;
  int V = scan!int;
  bool[][] S = scan!string(N).map!(s => s.map!(c => c == '1').array).array;
  bool[][] T = scan!string(N).map!(s => s.map!(c => c == '1').array).array;

  foreach(r; 0..N) foreach(c; 0..N) if (S[r][c] == T[r][c]) S[r][c] = T[r][c] = false;

  struct Coord {
    int r, c;

    int dist(inout Coord other) {
      return abs(r - other.r) + abs(c - other.c);
    }

    int size() {
      return abs(r) + abs(c);
    }

    Coord rotate(inout Coord base) {
      auto dr = r - base.r;
      auto dc = c - base.c;
      return Coord(base.r + dc, base.c - dr);
    }

    bool isValid() {
      return min(r, c) >= 0 && max(r, c) <= N - 1;
    }

    inout int opCmp(inout Coord other) {
      return cmp(
        [r, c],
        [other.r, other.c]
      );
    }
  }

  auto toPick = new Coord[](0).redBlackTree;
  auto toDrop = new Coord[](0).redBlackTree;

  foreach(r; 0..N) foreach(c; 0..N) {
    if (S[r][c] == T[r][c]) {
      S[r][c] = T[r][c] = false;
      continue;
    }

    if (S[r][c]) {
      toPick.insert(Coord(r, c));
    } else {
      toDrop.insert(Coord(r, c));
    }
  }

  struct Order {
    Coord from, to;
    int rotationTimes;
    Coord rotationBase;

    int armSize() {
      return from.dist(rotationBase);
    }

    bool rotateRight() {
      if (rotationTimes != 1) return true;

      auto r = from.rotate(rotationBase);
      auto l = r.rotate(rotationBase).rotate(rotationBase);
      return r.dist(to) <= l.dist(to);
    }

    int cost() {
      if (rotationTimes == 0) {
        return from.dist(to);
      }

      auto r = from.rotate(rotationBase);
      if (rotationTimes == 2) {
        return rotationTimes + r.rotate(rotationBase).dist(to);
      }

      auto l = r.rotate(rotationBase).rotate(rotationBase);
      return rotationTimes + min(r.dist(to), l.dist(to));
    }

    int pickDir() {
      auto dr = rotationBase.r == from.r ? 0 : rotationBase.r < from.r ? 1 : -1;
      auto dc = rotationBase.c == from.c ? 0 : rotationBase.c < from.c ? 1 : -1;

      if (dc == 1) return 0;
      if (dr == 1) return 1;
      if (dc == -1) return 2;
      if (dr == -1) return 3;
      return 0;
    }

    string toString() {
      return format(
        "Order: (%2d, %2d) => (%2d, %2d) via (%2d, %2d) * %d " ~
        "@ [arm:%2d, cost:%2d]",
        from.r, from.c, to.r, to.c,
        rotationBase.r, rotationBase.c, rotationTimes,
        armSize(), cost(),
      );
    }

    Order nearest(RedBlackTree!int armSizes) {
      auto arm = armSize();
      if (arm in armSizes) return this;

      if (armSize == 0) {
        arm = armSizes.front + 1;
        if (rotationBase.c < N / 2) rotationBase.c++; else rotationBase.c--;
      }

      auto dr = rotationBase.r == from.r ? 0 : rotationBase.r < from.r ? -1 : 1;
      auto dc = rotationBase.c == from.c ? 0 : rotationBase.c < from.c ? -1 : 1;
      foreach(d; 1..N) {
        foreach(a; [arm - d]) {
          Coord coord = Coord(from.r + dr*a, from.c + dc*a);
          if (!coord.isValid()) continue;

          // auto toRoot = Coord(to.r - dr*a, to.c - dc*a);
          // if (!toRoot.isValid()) continue;
          // [from, to, toRoot].deb;

          if (a in armSizes) {
            return Order(from, to, rotationTimes, coord);
          }
        }
      }

      return this;
    }
  }

  Order[] createOrders(Coord[] src, Coord[] dest) {
    Order[] ret;
    auto toDrop = dest.redBlackTree;
    foreach(from; src) {
      Coord[Coord][3] df;
      df[0][from] = from;
      foreach(dr, dc; zip([0, -1, 0, 1], [-1, 0, 1, 0])) {
        foreach(d; 0..N + 1) {
          auto base = Coord(from.r + d*dr, from.c + d*dc);
          if (!base.isValid()) break;

          auto r = from.rotate(base);
          df[1][r] = base;
          r = r.rotate(base);
          df[2][r] = base;
          r = r.rotate(base);
          df[1][r] = base;
        }
      }

      int minDist = int.max;
      int minD;
      Coord minBase, minTo;
      foreach(d; 0..3) foreach(rotated, base; df[d]) {
        foreach(to; toDrop) {
          auto dist = rotated.dist(to) + d;

          auto toRoot = Coord(base.r + to.r - rotated.r, base.c + to.c - rotated.c);
          if (!toRoot.isValid()) continue;

          if (minDist.chmin(dist)) {
            minD = d;
            minBase = base;
            minTo = to;
          }
        }
      }

      // minDist.deb;
      // [from, minBase, minTo].deb;
      ret ~= Order(from, minTo, minD, minBase);
      toDrop.removeKey(minTo);
    }
    return ret;
  }

  Coord cur = Coord(N / 2, N / 2);

  class Arm {
    int id, size, dir;
    bool picked;

    this(int id, int size, int dir) {
      this.id = id;
      this.size = size;
      this.dir = dir;
    }

    Coord coord() {
      int r = cur.r;
      int c = cur.c;
      if (dir == 0) c += size;
      if (dir == 1) r += size;
      if (dir == 2) c -= size;
      if (dir == 3) r -= size;
      return Coord(r, c);
    }

    void rotate(bool right = true) {
      if (right) dir++; else dir--;
      dir = (dir + 4) % 4;
    }

    override string toString() {
      return format(
        "Arm: #%2d, dir: %d, size: %2d, %s",
        id, dir, size, picked ? "PICKED" : "-",
      );
    }
  }

  Order[] orders = createOrders(toPick.array, toDrop.array);
  auto orderArmSizes = orders.map!"a.armSize".filter!"a > 0".array.sort;
  auto armSizes = new int[](0).redBlackTree;

  writeln(V);
  Arm[][] arms = new Arm[][](N + 1, 0);
  foreach(i; 0..V - 1) {
    auto armSize = orderArmSizes[min($ - 1, (i * orderArmSizes.length) / V)];
    writefln("%s %s", 0, armSize);
    arms[armSize] ~= new Arm(i + 1, armSize, 0);
    armSizes.insert(armSize);
  }
  writefln("%s %s", cur.r, cur.c);

  foreach(order; orders) {
    // if (order.rotationTimes == 0) continue;

    order.deb;
    order = order.nearest(armSizes);
    order.deb;

    Coord moveTo = order.rotationBase;
    while(moveTo.r != cur.r) {
      writeln((cur.r > moveTo.r ? 'U' : 'D') ~ '.'.repeat(2*V - 1).array);
      cur.r += cur.r > moveTo.r ? -1 : 1;
    }
    while(moveTo.c != cur.c) {
      writeln((cur.c > moveTo.c ? 'L' : 'R') ~ '.'.repeat(2*V - 1).array);
      cur.c += cur.c > moveTo.c ? -1 : 1;
    }

    auto arm = arms[order.armSize()][0];
    auto deltaDir = (order.pickDir() + 4 - arm.dir) % 4;

    auto rotate = repeat('.', 2*V).array;
    if (deltaDir == 3) {
      rotate[arm.id] = 'L';
      writeln(rotate);
      arm.rotate(false);
    } else {
      rotate[arm.id] = 'R';
      foreach(_; 0..deltaDir) {
        writeln(rotate);
        arm.rotate(true);
      }
    }
    
    auto pick = repeat('.', 2*V).array;
    pick[V + arm.id] = 'P';
    writeln(pick);

    foreach(_; 0..order.rotationTimes) {
      auto right = order.rotateRight();
      if (right) {
        rotate[arm.id] = 'R';
        writeln(rotate);
        arm.rotate(true);
      } else {
        rotate[arm.id] = 'L';
        writeln(rotate);
        arm.rotate(false);
      }
    }

    moveTo = order.to;
    // deb(arm, [cur, moveTo, arm.coord]);
    while(moveTo.r != arm.coord.r) {
      writeln((arm.coord.r > moveTo.r ? 'U' : 'D') ~ '.'.repeat(2*V - 1).array);
      cur.r += arm.coord.r > moveTo.r ? -1 : 1;
    }
    while(moveTo.c != arm.coord.c) {
      writeln((arm.coord.c > moveTo.c ? 'L' : 'R') ~ '.'.repeat(2*V - 1).array);
      cur.c += arm.coord.c > moveTo.c ? -1 : 1;
    }

    cur.deb;
    if (!cur.isValid()) {
      assert(false, "The root coordinate is out of range.");
    }
    writeln(pick);
  }
}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("# "); writeln(t); }}
// void deb(T ...)(T t){ debug {  }}
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
