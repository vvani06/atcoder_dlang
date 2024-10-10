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

    Coord move(char m) {
      if (m == 'D') return Coord(r + 1, c);
      if (m == 'U') return Coord(r - 1, c);
      if (m == 'R') return Coord(r, c + 1);
      if (m == 'L') return Coord(r, c - 1);
      return this;
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

    bool equals(Coord other) {
      return r == other.r && c == other.c;
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

  final class Order {
    Coord from, to;
    int rotationTimes;
    Coord pickFrom;
    
    Coord dropFrom;

    this(Coord from, Coord to, int rotationTimes, Coord pickFrom) {
      this.from = from;
      this.to = to;
      this.rotationTimes = rotationTimes;
      this.pickFrom = pickFrom;

      auto rotated = fromRotated();
      dropFrom = Coord(pickFrom.r + to.r - rotated.r, pickFrom.c + to.c - rotated.c);
    }

    int armSize() {
      return from.dist(pickFrom);
    }

    bool rotateRight() {
      if (rotationTimes != 1) return true;

      auto r = from.rotate(pickFrom);
      auto l = r.rotate(pickFrom).rotate(pickFrom);
      return r.dist(to) <= l.dist(to);
    }

    int cost() {
      if (rotationTimes == 0) {
        return from.dist(to);
      }

      auto r = from.rotate(pickFrom);
      if (rotationTimes == 2) {
        return rotationTimes + r.rotate(pickFrom).dist(to);
      }

      auto l = r.rotate(pickFrom).rotate(pickFrom);
      return rotationTimes + min(r.dist(to), l.dist(to));
    }

    Coord fromRotated() {
      auto r = from;
      if (rotateRight()) {
        foreach(_; 0..rotationTimes) r = r.rotate(pickFrom);
      } else {
        foreach(_; 0..3) r = r.rotate(pickFrom);
      }
      return r;
    }

    int pickDir() {
      auto dr = pickFrom.r == from.r ? 0 : pickFrom.r < from.r ? 1 : -1;
      auto dc = pickFrom.c == from.c ? 0 : pickFrom.c < from.c ? 1 : -1;

      if (dc == 1) return 0;
      if (dr == 1) return 1;
      if (dc == -1) return 2;
      if (dr == -1) return 3;
      return 0;
    }

    int dropDir() {
      auto ret = pickDir();
      if (rotationTimes == 0) return ret;

      if (rotateRight) {
        ret += rotationTimes;
      } else {
        ret += 3;
      }
      return ret % 4;
    }

    override string toString() {
      return format(
        "Order: (%2d, %2d) => (%2d, %2d) via (%2d, %2d) * %d " ~
        "@ [arm:%2d, cost:%2d]",
        from.r, from.c, to.r, to.c,
        pickFrom.r, pickFrom.c, rotationTimes,
        armSize(), cost(),
      );
    }

    Order nearest(T)(T armSizes) {
      auto arm = armSize();
      if (arm in armSizes) return this;

      if (armSize == 0) {
        arm = armSizes.front + 1;
        if (pickFrom.c < N / 2) pickFrom.c++; else pickFrom.c--;
      }

      auto dr = pickFrom.r == from.r ? 0 : pickFrom.r < from.r ? -1 : 1;
      auto dc = pickFrom.c == from.c ? 0 : pickFrom.c < from.c ? -1 : 1;
      foreach(d; 1..N) {
        foreach(a; [arm - d]) {
          Coord coord = Coord(from.r + dr*a, from.c + dc*a);
          if (!coord.isValid()) continue;

          // auto toRoot = Coord(to.r - dr*a, to.c - dc*a);
          // if (!toRoot.isValid()) continue;
          // [from, to, toRoot].deb;

          if (a in armSizes) {
            return new Order(from, to, rotationTimes, coord);
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
      ret ~= new Order(from, minTo, minD, minBase);
      toDrop.removeKey(minTo);
    }
    return ret;
  }

  class Robot {
    Coord root;

    Arm[] arms;
    Order[] orderByArm;
    int currentOrderArmIndex;

    this(Coord start, int[] armSizes) {
      root = start;
      currentOrderArmIndex = -1;

      foreach(i, s; armSizes.enumerate(1)) {
        arms ~= new Arm(this, i, s, 0);
      }
      orderByArm = new Order[](arms.length);
      arms.each!deb;
    }

    void takeOrders(ref bool[Order] orders) {
      foreach(Order order; orders.keys.sort!((a, b) => root.dist(a.pickFrom) < root.dist(b.pickFrom))) {
        foreach(i, arm; arms.enumerate(0)) {
          if (orderByArm[i]) continue;

          auto armSize = order.armSize();
          if (arm.size != armSize) continue;

          orderByArm[i] = order;
          orders.remove(order);
          break;
        }
      }

      if (currentOrderArmIndex == -1) {
        int minDist = int.max;
        foreach(i, arm, order; zip(arms.length.to!int.iota, arms, orderByArm)) {
          if (order is null) continue;

          if (!arm.picked) {
            if (minDist.chmin(root.dist(order.pickFrom))) {
              currentOrderArmIndex = i;
            }
          } else {
            if (minDist.chmin(root.dist(order.dropFrom))) {
              currentOrderArmIndex = i;
            }
          }
        }
      }
    }

    string[] initialize() {
      string[] ret;
      ret ~= format("%d", V);
      foreach(arm; arms) ret ~= format("%d %d", 0, arm.size);
      ret ~= format("%d %d", root.r, root.c);
      return ret;
    }

    string simulate() {
      auto ret = '.'.repeat(2 * V).array;

      void rotate(Arm arm, bool right) {
        ret[arm.id] = right ? 'R' : 'L';
        arm.rotate(right);
      }

      void toggle(Arm arm) {
        ret[V + arm.id] = 'P';
      }

      void move(Coord from, Coord to) {
        if (to.r > from.r) {
          ret[0] = 'D';
        } else if (to.r < from.r) {
          ret[0] = 'U';
        } else if (to.c > from.c) {
          ret[0] = 'R';
        } else if (to.c < from.c) {
          ret[0] = 'L';
        }
        root = root.move(ret[0]);
      }

      // 回転すべきアームがある
      foreach(arm, order; zip(arms, orderByArm)) {
        if (order is null) continue;

        if (!arm.picked) {
          auto deltaDir = (order.pickDir() + 4 - arm.dir) % 4;
          if (deltaDir != 0) rotate(arm, deltaDir != 3);
        } else {
          auto deltaDir = (order.dropDir() + 4 - arm.dir) % 4;
          if (deltaDir != 0) rotate(arm, deltaDir != 3);
        }
      }

      // Pick/Drop できるやつがある
      bool toggled;
      foreach(arm, order; zip(arms, orderByArm)) {
        if (order is null) continue;

        if (!arm.picked) {
          if (arm.coord.equals(order.from)) {
            toggle(arm);
            toggled = true;
          }
        } else {
          if (arm.coord.equals(order.to)) {
            toggle(arm);
            toggled = true;
          }
        }
      }

      // これまでに Pick/Drop できるやつがない場合だけ移動して、移動後のPick/Dropをやる
      if (!toggled && currentOrderArmIndex >= 0) {
        {
          auto arm = arms[currentOrderArmIndex];
          auto order = orderByArm[currentOrderArmIndex];
          auto dest = arm.picked ? order.dropFrom : order.pickFrom;
          move(root, dest);
        }

        foreach(arm, order; zip(arms, orderByArm)) {
          if (order is null) continue;

          if (!arm.picked) {
            if (arm.coord.equals(order.from)) {
              toggle(arm);
            }
          } else {
            if (arm.coord.equals(order.to)) {
              toggle(arm);
            }
          }
        }
      }

      foreach(i, arm, order; zip(arms.length.iota, arms, orderByArm)) {
        if (order is null) continue;

        if (ret[V + arm.id] == 'P') {
          if (arm.picked) {
            orderByArm[i] = null;
          }
          arm.picked ^= true;
          if (i == currentOrderArmIndex) currentOrderArmIndex = -1;
        }
      }

      return ret.to!string;
    }

    class Arm {
      Robot robot;
      int id, size, dir;
      bool picked;

      this(Robot robot, int id, int size, int dir) {
        this.robot = robot;
        this.id = id;
        this.size = size;
        this.dir = dir;
      }

      Coord coord() {
        int r = robot.root.r;
        int c = robot.root.c;
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
          "Arm: #%2d (%2d, %2d) dir: %d, size: %2d, %s",
          id, coord().r, coord().c, dir, size, picked ? "PICKED" : "-",
        );
      }
    }
  }

  Order[] orders = createOrders(toPick.array, toDrop.array);
  auto armSizes = new int[](0).redBlackTree!true; {
    auto orderArmSizes = orders.map!"a.armSize".filter!"a > 0".array.sort;
    foreach(i; 0..V - 1) {
      auto armSize = orderArmSizes[min($ - 1, (i * orderArmSizes.length) / V)];
      armSizes.insert(armSize);
    }
  }

  orders = orders.map!(order => order.nearest(armSizes)).array;
  Coord cur; {
    int[Coord] coordCount;
    int maxi;
    foreach(order; orders) {
      coordCount[order.pickFrom]++;
      if (maxi.chmax(coordCount[order.pickFrom])) cur = order.pickFrom;
    }
  }
  Robot robot = new Robot(cur, armSizes.array);

  bool[Order] ordersMap;
  foreach(order; orders) ordersMap[order] = true;
  robot.takeOrders(ordersMap);

  robot.orderByArm.each!deb;

  foreach(s; robot.initialize()) writeln(s);
  while(true) {
    auto moves = robot.simulate();
    if (moves.all!"a == '.'") break;

    writeln(moves);
    robot.takeOrders(ordersMap);
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
