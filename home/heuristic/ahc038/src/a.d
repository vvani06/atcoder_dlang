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
    int r, c, dir;

    int dist(Coord other) {
      return abs(r - other.r) + abs(c - other.c);
    }

    int size() {
      return abs(r) + abs(c);
    }

    Coord rotate(Coord base) {
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

    Coord[] armed(int d) {
      return [
        Coord(r, c + d, 0),
        Coord(r + d, c, 1),
        Coord(r, c - d, 2),
        Coord(r - d, c, 3),
      ].filter!(coord => coord.isValid()).array;
    }


    T of(T)(ref T[][] t) {
      return t[r][c];
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
    foreach(from; src.randomShuffle) {
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

  class PickDrop {
    int armSize;
    Coord coord;
    int cost;

    this(int armSize, Coord coord, int dir, int cost) {
      this.armSize = armSize;
      this.coord = Coord(coord.r, coord.c, dir);
      this.cost = cost;
    }

    int dir() {
      return coord.dir;
    }

    Coord dest() {
      int dr = dir == 1 ? armSize : dir == 3 ? -armSize : 0;
      int dc = dir == 0 ? armSize : dir == 2 ? -armSize : 0;
      return Coord(coord.r + dr, coord.c + dc);
    }

    override string toString() {
      return "PickDrop { (%2d, %2d) => [%2d * %d] => (%2d, %2d) | Cost: %2d } ".format(
        coord.r, coord.c,
        armSize, coord.dir,
        dest.r, dest.c,
        cost,
      );
    }
  }

  final class Robot {
    Coord root;

    Arm[] arms;
    PickDrop[] orderByArm;
    int currentOrderArmIndex;

    bool[][] pickGrid, dropGrid;

    this(Coord start, int[] armSizes, bool[][] pg, bool[][] dg) {
      root = start;
      pickGrid = pg.map!"a.dup".array;
      dropGrid = dg.map!"a.dup".array;
      currentOrderArmIndex = -1;

      foreach(i, s; armSizes.enumerate(1)) {
        arms ~= new Arm(this, i, s, 0);
        orderByArm ~= null;
        arms[i - 1].deb;
      }
    }

    PickDrop search(int armSize, bool drop = false) {
      bool[31][31] visited;
      int[31][31] costs;
      costs[root.r][root.c] = 1;
      
      for(auto queue = DList!Coord([root]); !queue.empty;) {
        auto cur = queue.front();
        queue.removeFront();

        if (visited[cur.r][cur.c]) continue;
        visited[cur.r][cur.c] = true;

        foreach(dest; cur.armed(armSize)) {
          if ((!drop && pickGrid[dest.r][dest.c]) || (drop && dropGrid[dest.r][dest.c])) {
            return new PickDrop(armSize, cur, dest.dir, costs[cur.r][cur.c]);
          }
        }

        foreach(ar; cur.armed(1)) {
          if (visited[ar.r][ar.c]) continue;

          queue.insertBack(ar);
          costs[ar.r][ar.c] = costs[cur.r][cur.c] + 1;
        }
      }

      return null;
    }

    PickDrop[] searchN(int limit, int armSize, bool drop = false) {
      PickDrop[] ret;
      bool[31][31] visited;
      int[31][31] costs;
      costs[root.r][root.c] = 1;

      for(auto queue = DList!Coord([root]); !queue.empty;) {
        auto cur = queue.front();
        queue.removeFront();

        if (visited[cur.r][cur.c]) continue;
        visited[cur.r][cur.c] = true;

        foreach(dest; cur.armed(armSize)) {
          if (visited[dest.r][dest.c]) continue;
          
          if ((!drop && pickGrid[dest.r][dest.c]) || (drop && dropGrid[dest.r][dest.c])) {
            ret ~= new PickDrop(armSize, cur, dest.dir, costs[cur.r][cur.c]);
            visited[dest.r][dest.c] = true;
          }
        }

        if (ret.length >= limit) break;

        foreach(ar; cur.armed(1)) {
          if (visited[ar.r][ar.c]) continue;

          queue.insertBack(ar);
          costs[ar.r][ar.c] = costs[cur.r][cur.c] + 1;
        }
      }

      return ret;
    }

    PickDrop research(int armIndex) {
      if (orderByArm[armIndex] is null) return null;

      auto armSize = arms[armIndex].size;
      auto target = orderByArm[armIndex].dest();
      bool[31][31] visited;
      int[31][31] costs;
      costs[root.r][root.c] = 1;

      for(auto queue = DList!Coord([root]); !queue.empty;) {
        auto cur = queue.front();
        queue.removeFront();

        if (visited[cur.r][cur.c]) continue;
        visited[cur.r][cur.c] = true;

        foreach(dest; cur.armed(armSize)) {
          if (dest.equals(target)) return new PickDrop(armSize, cur, dest.dir, costs[cur.r][cur.c]);
        }

        foreach(ar; cur.armed(1)) {
          if (visited[ar.r][ar.c]) continue;

          queue.insertBack(ar);
          costs[ar.r][ar.c] = costs[cur.r][cur.c] + 1;
        }
      }

      return null;
    }

    void takeOrders() {
      /+
      foreach(i, arm; arms.enumerate(0)) {
        if (orderByArm[i]) {
          orderByArm[i] = research(i);
          continue;
        }
        
        PickDrop order = search(arm.size, false);
        PickDrop testDrop = search(arm.size, true);
        if (order && testDrop) {
          pickGrid[order.dest.r][order.dest.c] = false;
          orderByArm[i] = order;
        }
      }
      +/

      auto freeArmCount = orderByArm.count!(order => order is null).to!int;
      PickDrop[] ordersCandidate = new PickDrop[](0);
      foreach_reverse(i, arm; arms.enumerate(0)) {
        if (orderByArm[i]) {
          orderByArm[i] = research(i);
          continue;
        }
        
        ordersCandidate ~= searchN(freeArmCount, arm.size, false);
      }

      foreach(order; ordersCandidate.multiSort!("a.cost < b.cost", "a.armSize > b.armSize")) {
        foreach(i, arm; arms.enumerate(0)) {
          if (orderByArm[i] || arm.size != order.armSize) continue;
          if (!pickGrid[order.dest.r][order.dest.c]) continue;

          pickGrid[order.dest.r][order.dest.c] = false;
          orderByArm[i] = order;
          break;
        }
      }

      int nearest = int.max;
      currentOrderArmIndex = -1;
      int[][Coord] counts;
      foreach(i, order; orderByArm.enumerate(0)) {
        if (order is null) continue;

        counts[order.coord] ~= i;
        if (nearest.chmin(root.dist(order.coord))) currentOrderArmIndex = i;
      }

      int bestSize;
      foreach(k; counts.keys.sort!((a, b) => root.dist(a) < root.dist(b))) {
        auto v = counts[k];
        if (bestSize.chmax(v.length.to!int)) {
          currentOrderArmIndex = v[0];
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
          auto deltaDir = (order.dir + 4 - arm.dir) % 4;
          if (deltaDir != 0) rotate(arm, deltaDir != 3);
        } else {
          auto deltaDir = (order.dir + 4 - arm.dir) % 4;
          if (deltaDir != 0) rotate(arm, deltaDir != 3);
        }
      }

      // Pick/Drop できるやつがある
      bool toggled;
      foreach(arm, order; zip(arms, orderByArm)) {
        if (order is null) continue;

        if (root.equals(order.coord) && arm.dir == order.dir) {
          toggle(arm);
          toggled = true;
        }
      }

      // これまでに Pick/Drop できるやつがない場合だけ移動して、移動後のPick/Dropをやる
      if (!toggled && currentOrderArmIndex >= 0) {
        {
          auto arm = arms[currentOrderArmIndex];
          auto order = orderByArm[currentOrderArmIndex];
          auto dest = order.coord;
          move(root, dest);
        }

        foreach(arm, order; zip(arms, orderByArm)) {
          if (order is null) continue;

          if (root.equals(order.coord) && arm.dir == order.dir) {
            toggle(arm);
          }
        }
      }

      foreach(i, arm; arms.enumerate(0)) {
        if (orderByArm[i] is null) continue;

        if (ret[V + arm.id] == 'P') {
          if (!arm.picked) {
            auto drop = search(arm.size, true);
            orderByArm[i] = drop;
            dropGrid[drop.dest.r][drop.dest.c] = false;
          } else {
            orderByArm[i] = null;
          }

          arm.picked ^= true;
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
          id, coord().r, coord().c, dir, size, picked ? "P" : "-",
        );
      }
    }
  }

  Robot[] robots;
  string[][] anss;

  { // pattern 1 - 最初に拾える数だけで貪欲に
    Coord bestStartCoord;
    int[] armsCandidates = new int[](0);
    {
      long maxCandidateSize;
      foreach(r; 0..N) foreach(c; 0..N) {
        int[] candidates;
        foreach_reverse(d; 1..N / 2 + 1) {
          foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
            auto coord = Coord(r + d*dr, c + d*dc);
            if (!coord.isValid()) continue;

            if (coord.of(S)) {
              candidates ~= d;
            }
          }
        }

        if (maxCandidateSize.chmax(candidates.length)) {
          armsCandidates = candidates;
          bestStartCoord = Coord(r, c);
        }
      }
      armsCandidates ~= armsCandidates.mean.to!int.repeat(V).array;
      armsCandidates = armsCandidates[0..V - 1].sort.array;
    }

    robots ~= new Robot(bestStartCoord, armsCandidates, S, T);
  }

  { // pattern 2 - アーム超ごとのスコア算出をもとに貪欲に
    enum int SCORE_MAX = 512;
    int[][] dropScore = new int[][](N, N);
    foreach(coord; toDrop) {
      bool[][] visited = new bool[][](N, N);

      bool[Coord] nexts = [coord: true];
      int step = 0;
      while(!nexts.empty) {
        auto keys = nexts.keys;
        nexts.clear;

        foreach(c; keys) {
          dropScore[c.r][c.c] += SCORE_MAX / (4^^step);
          visited[c.r][c.c] = true;

          foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
            auto n = Coord(c.r + dr, c.c + dc);
            if (!n.isValid || visited[n.r][n.c]) continue;

            nexts[n] = true;
          }
        }
        step++;

        if (SCORE_MAX / (8^^step) == 0) break;
      }
    }

    int[] armsCandidates = new int[](0);
    int[] armSizeScore = new int[](N + 1);
    {
      foreach(from; toPick) {
        foreach(d; 1..N + 1) {
          int maxScore;
          foreach(dr, dc; zip([-2, -1, 0, 1, 2, 1, 0, -1], [0, -1, -2, -1, 0, 1, 2, 1])) {
            auto rotated = Coord(from.r + d*dr, from.c + d*dc);
            if (!rotated.isValid()) continue;

            maxScore.chmax(dropScore[rotated.r][rotated.c]);
          }
          armSizeScore[d] += maxScore;
        }
      }
      
      // armSizeScore.deb;
      int[] arms = new int[](0);
      foreach(_; 0..V - 1) {
        arms ~= armSizeScore.maxIndex.to!int;
        armSizeScore[armSizeScore.maxIndex] *= 7;
        armSizeScore[armSizeScore.maxIndex] /= 10;
      }
      armsCandidates = arms.sort.array;
    }

    int[][] gridScore = new int[][](N, N);
    Coord bestStartCoord;
    int bestStartScore;
    foreach(r; 0..N) foreach(c; 0..N) {
      foreach(d, count; armsCandidates.group) {
        int[] adds = new int[](0);
        foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
          auto coord = Coord(r + d*dr, c + d*dc);
          if (!coord.isValid()) continue;

          adds ~= (coord in toPick) ? 1 : 0;
        }

        gridScore[r][c] += adds.sort!"a > b"[0..min($, count)].sum;
      }
      if (bestStartScore.chmax(gridScore[r][c])) {
        bestStartCoord = Coord(r, c);
      }
    }
    robots ~= new Robot(bestStartCoord, armsCandidates, S, T);
  }

  string[] ans;
  long best = long.max;
  foreach(i, robot; robots.enumerate(0)) {
    string[] output;
    output ~= robot.initialize();

    robot.takeOrders();
    foreach(turn; 1..10^^5) {
      // zip(robot.arms, robot.orderByArm).each!(r => deb(r[0], " / ", r[1]));

      auto moves = robot.simulate();
      if (moves.all!"a == '.'") break;

      // [turn].deb;
      // zip(robot.arms, robot.orderByArm).each!(r => deb(r[0], " / ", r[1]));

      output ~= moves;
      robot.takeOrders();
    }

    long penalty = robot.dropGrid.joiner.count(true) * 10^^5;
    if (best.chmin(output.length + penalty)) ans = output;
  }

  foreach(row; ans) writeln(row);
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
