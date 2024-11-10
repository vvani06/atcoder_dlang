module home.heuristic.ahc038.src.b;

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
  enum DIR_DELTA = zip([0, 1, 0, -1], [1, 0, -1, 0]);

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
      }
    }

    bool[31][31] visited;
    bool[31][31] queued;
    int[31][31] costs;
    void provisionSearch() {
      foreach(i; 0..31) {
        visited[i][] = false;
        queued[i][] = false;
        costs[i][] = 0;
      }
    }

    PickDrop search(int armSize, bool drop = false) {
      provisionSearch();
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
      provisionSearch();
      PickDrop[] ret;
      costs[root.r][root.c] = 1;

      for(auto queue = DList!Coord([root]); !queue.empty;) {
        auto cur = queue.front();
        queue.removeFront();

        if (visited[cur.r][cur.c]) continue;
        visited[cur.r][cur.c] = true;

        foreach(dest; cur.armed(armSize)) {
          if (queued[dest.r][dest.c]) continue;
          
          if ((!drop && pickGrid[dest.r][dest.c]) || (drop && dropGrid[dest.r][dest.c])) {
            ret ~= new PickDrop(armSize, cur, dest.dir, costs[cur.r][cur.c]);
            queued[dest.r][dest.c] = true;
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

    void takeOrders() {
      foreach(i, arm; arms.enumerate(0)) {
        if (i == currentOrderArmIndex || !orderByArm[i] || root.equals(orderByArm[i].coord)) continue;

        auto dest = orderByArm[i].dest;
        orderByArm[i] = null;
        if (!arm.picked) {
          pickGrid[dest.r][dest.c] = true;
        } else {
          dropGrid[dest.r][dest.c] = true;
        }
      }

      { // find pick points
        PickDrop[] ordersCandidate = new PickDrop[](0);
        foreach(i, arm; arms.enumerate(0)) {
          if (!orderByArm[i] && !arm.picked) {
            ordersCandidate ~= searchN(V, arm.size, false);
          }
        }

        int[Coord] coordCounts;
        foreach(ref order; ordersCandidate) {
          coordCounts[order.dest]++;
        }

        [root].deb;
        foreach(order; ordersCandidate.multiSort!("a.cost < b.cost", (a, b) => (coordCounts[a.dest] < coordCounts[b.dest]))) {
          if (!pickGrid[order.dest.r][order.dest.c]) continue;

          foreach(i, arm; arms.enumerate(0)) {
            if (arm.picked || orderByArm[i] || arm.size != order.armSize) continue;

            pickGrid[order.dest.r][order.dest.c] = false;
            orderByArm[i] = order;
            break;
          }
        }
      }

      { // find drop points
        PickDrop[] ordersCandidate = new PickDrop[](0);
        foreach(i, arm; arms.enumerate(0)) {
          if (!orderByArm[i] && arm.picked) {
            ordersCandidate ~= searchN(V, arm.size, true);
          }
        }

        int[Coord] coordCounts;
        foreach(order; ordersCandidate) {
          coordCounts[order.dest]++;
        }

        foreach(order; ordersCandidate.multiSort!("a.cost < b.cost", (a, b) => (coordCounts[a.dest] < coordCounts[b.dest]))) {
          if (!dropGrid[order.dest.r][order.dest.c]) continue;

          foreach(i, arm; arms.enumerate(0)) {
            if (!arm.picked || orderByArm[i] || arm.size != order.armSize) continue;

            dropGrid[order.dest.r][order.dest.c] = false;
            orderByArm[i] = order;
            break;
          }
        }
      }

      {
        int best = int.max;
        int bestIndex = -1;
        foreach(i, order; orderByArm.enumerate(0)) {
          if (!order) continue;
          
          if (best.chmin(root.dist(order.coord) + (arms[i].picked ? (20 - V) / 3 : 0))) {
            bestIndex = i;
          } 
        }

        auto currentCost = currentOrderArmIndex == -1 || orderByArm[currentOrderArmIndex] is null ? int.max : root.dist(orderByArm[currentOrderArmIndex].coord);
        if (currentCost > best) currentOrderArmIndex = bestIndex;
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
          orderByArm[i] = null;
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
        foreach(d; 1..N / 2 + 2) {
          int maxScore;
          foreach(dr, dc; zip([-2, -1, 0, 1, 2, 1, 0, -1], [0, -1, -2, -1, 0, 1, 2, 1])) {
            auto rotated = Coord(from.r + d*dr, from.c + d*dc);
            if (!rotated.isValid()) continue;

            maxScore.chmax(dropScore[rotated.r][rotated.c]);
          }
          armSizeScore[d] += maxScore * d;
        }
      }
      
      // armSizeScore.deb;
      int[] arms = new int[](0);
      foreach(_; 0..V - 1) {
        arms ~= armSizeScore.maxIndex.to!int;
        armSizeScore[armSizeScore.maxIndex] *= 5;
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
  { // pattern 3 - アーム超ごとのスコア算出をもとに貪欲に2
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
        foreach(d; 1..N / 2 + 1) {
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
        armSizeScore[armSizeScore.maxIndex] *= 5;
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
  {
    static struct Coord2 {
      int r, c;

      Coord2 opBinary(string op: "+")(Coord2 other) const {
        return Coord2(r + other.r, c + other.c);
      }
      Coord2 opBinary(string op: "-")(Coord2 other) const {
        return Coord2(r - other.r, c - other.c);
      }
      Coord2 opBinary(string op: "*")(int d) const {
        return Coord2(r * d, c * d);
      }
      auto opOpAssign(string op)(Coord2 t) {
        return mixin ("this = this " ~ op ~ " t");
      }
      static Coord2 arm(int size, int dir) {
        return Coord2(DIR_DELTA[dir][0] * size, DIR_DELTA[dir][1] * size);
      }
      bool invalid(int N) {
        return min(r, c) < 0 || max(r, c) >= N;
      }
      T of(T)(T[][] t) const {
        return t[r][c];
      }
    }

    int distanceDirs(int[] d1, int[] d2) {
      return zip(d1, d2).map!(a => a[0] == a[1] ? 0 : (a[0] + a[1]) % 2 == 0 ? 2 : 1).maxElement;
    }

    char[] calcRotate(int[] d1, int[] d2) {
      return zip(d1, d2).map!(a => a[0] == a[1] ? '.' : (a[1] + 4 - a[0]) % 4 == 3 ? 'L' : 'R').array;
    }

    int[] rotate(int[] d1, char[] r) {
      return zip(d1, r).map!(a => (a[1] == 'L' ? a[0] + 3 : a[1] == 'R' ? a[0] + 1 : a[0]) % 4).array;
    }

    foreach(r; 0..N) foreach(c; 0..N) if (S[r][c] == T[r][c]) S[r][c] = T[r][c] = false;

    int armScale = min(V - 1, N >= 18 ? 5 : 4);
    int[] armSizes = iota(armScale - 1, -1, -1).map!"2 ^^ a".array;
    int armLimit = 2^^armScale + 1;

    class Arm {
      int id;
      int scale;
      int[] dirs;

      int[][Coord2] templateArmDirs;
      Coord2[] templateArmCoords;

      this(int id, int scale) {
        this.id = id;
        this.scale = scale;
        this.dirs = new int[](scale);
        foreach(dirs; basePacks(4, scale)) {
          Coord2 coord;
          int dir;
          foreach(i, d; dirs.enumerate(0)) {
            dir = (dir + d) % 4;
            auto armSize = 2^^(scale - 1 - i);
            coord += Coord2.arm(armSize, dir);
          }
          this.templateArmDirs[coord] = dirs;
          this.templateArmCoords ~= coord;
        }
        this.templateArmCoords.sort!((a, b) => abs(a.r) * 5 + abs(a.c) > abs(b.r) * 5 + abs(b.c));
      }
    }
    
    class Robot2 {
      Coord2 root;
      Arm[] arms;

      this() {
        root = Coord2(0, 0);
        arms = new Arm[](0);
      }

      int moveRotationL(int armId) {
        int ret = 1;
        foreach(i, arm; arms.enumerate(0)) {
          if (i == armId) break;

          ret += arm.scale;
        }
        return ret;
      }

      int moveRotationR(int armId) {
        return moveRotationL(armId) + arms[armId].scale;
      }

      int movePick(int armId) {
        int ret = moveRotationR(arms.length.to!int - 1);
        foreach(i, arm; arms.enumerate(0)) {
          ret += arm.scale;
          if (i == armId) break;
        }
        return ret;
      }

      string[] initialize() {
        int v = 1;
        foreach(arm; arms) v += arm.scale;
        
        string[] ret;
        ret ~= "%s".format(v);

        int offset;
        foreach(arm; arms) {
          foreach(j; 0..arm.scale) {
            ret ~= "%s %s".format(j == 0 ? 0 : offset + j, 2^^(arm.scale - 1 - j));
          }
          offset += arm.scale;
        }
        ret ~= "%s %s".format(root.r, root.c);
        return ret;
      }

      char[] moveTemplate() {
        return '.'.repeat(2 * V).array;
      }
    }

    Coord2 root = Coord2(N / 2, min(N / 2, armLimit - N / 2));
    Robot2 robot = new Robot2(); {
      robot.root = root;
      int armId;
      for(int v = V - 1; v > 0;) {
        auto scale = min(armScale, v);
        v -= scale;

        robot.arms ~= new Arm(armId++, scale);
      }
    }
    foreach(a; robot.initialize) ans ~= a;

    // foreach(i, arm; robot.arms.enumerate(0)) {
    //   [robot.moveRotationL(i),robot.moveRotationR(i),robot.movePick(i)].deb;
    // }
    // robot.initialize().each!deb;

    auto pickGrid = S.map!"a.dup".array;
    auto dropGrid = T.map!"a.dup".array;
    alias Order = Tuple!(int, "armId", int, "pickDirDist", Coord2, "pickCoord", int, "dropDirDist", Coord2, "dropCoord");
    int lastParity;
    int rest = pickGrid.joiner.count(true).to!int;

    while(rest > 0) {
      foreach(parity; zip([0, 0, 1, 1], [0, 1, 0, 1])) {
        foreach(_; 0..1000) {
          Order[] orders;
          
          auto pickRoot = root + Coord2(-parity[0], 0);
          auto dropRoot = root + Coord2(-parity[1], 0);

          foreach_reverse(armId, arm; robot.arms.enumerate(0)) {
            Coord2 pickCoord;
            int pickDirDist = int.max;
            foreach(armCoord; arm.templateArmCoords) {
              auto coord = pickRoot + armCoord;
              if (coord.invalid(N) || !coord.of(pickGrid)) continue;

              auto pickDir = arm.templateArmDirs[armCoord];
              if (pickDirDist.chmin(distanceDirs(arm.dirs, pickDir))) {
                pickCoord = armCoord;
              }
            }
            if (pickDirDist == int.max) continue;

            Coord2 dropCoord;
            int dropDirDist = int.max;
            foreach(armCoord; arm.templateArmCoords) {
              auto coord = dropRoot + armCoord;
              if (coord.invalid(N) || !coord.of(dropGrid)) continue;

              auto dropDir = arm.templateArmDirs[armCoord];
              auto pickDir = arm.templateArmDirs[pickCoord];
              if (dropDirDist.chmin(distanceDirs(pickDir, dropDir))) {
                dropCoord = armCoord;
              }
            }
            if (dropDirDist == int.max) continue;

            auto pc = pickRoot + pickCoord;
            pickGrid[pc.r][pc.c] = false;
            auto dc = dropRoot + dropCoord;
            dropGrid[dc.r][dc.c] = false;
            orders ~= Order(armId, pickDirDist, pickCoord, dropDirDist, dropCoord);
          }

          if (orders.empty) break;

          char[][] moves = 4.iota.map!(_ => robot.moveTemplate.dup).array;
          int maxDrop;
          foreach(order; orders) {
            auto arm = robot.arms[order.armId];
            auto ml = robot.moveRotationL(order.armId);
            auto mr = robot.moveRotationR(order.armId);
            auto mp = robot.movePick(order.armId);

            int pickMove = max(1, order.pickDirDist);
            foreach(i; 0..pickMove) {
              auto rot = calcRotate(arm.dirs, arm.templateArmDirs[order.pickCoord]);
              arm.dirs = rotate(arm.dirs, rot);
              moves[i][ml .. mr] = rot;
            }
            moves[pickMove - 1][mp] = 'P';

            int dropMove = max(1, order.dropDirDist);
            foreach(i; pickMove..pickMove + dropMove) {
              auto rot = calcRotate(arm.dirs, arm.templateArmDirs[order.dropCoord]);
              arm.dirs = rotate(arm.dirs, rot);
              moves[i][ml .. mr] = rot;
            }
            maxDrop = max(maxDrop, pickMove + dropMove - 1);
          }

          foreach(order; orders) {
            auto mp = robot.movePick(order.armId);
            moves[maxDrop][mp] = 'P';
          }

          if (lastParity != parity[0]) {
            moves[0][0] = lastParity == 0 ? 'U' : 'D';
          }
          if (parity[0] != parity[1]) {
            moves[maxDrop][0] = parity[0] == 0 ? 'U' : 'D';
          }
          lastParity = parity[1];
          rest -= orders.length.to!int;
          foreach(m; moves) {
            if (m == robot.moveTemplate) break; else ans ~= m.to!string;
          }
        }
      }

      if (rest > 0 && root.c < N - 1) {
        root += Coord2(0, 1);
        auto moveRight = robot.moveTemplate.dup;
        moveRight[0] = 'R';
        ans ~= moveRight.to!string;
      } else {
        break;
      }
    }
    best = ans.length + rest * 10^^5;
  }

  foreach(i, robot; robots.enumerate(0)) {
    string[] output;
    output ~= robot.initialize();

    robot.takeOrders();
    foreach(turn; 1..2000) {
      // zip(robot.arms, robot.orderByArm).each!(r => deb(r[0], " / ", r[1]));

      auto moves = robot.simulate();
      if (moves.all!"a == '.'") break;

      [turn, robot.pickGrid.joiner.count(true), robot.dropGrid.joiner.count(true)].deb;
      // zip(robot.arms, robot.orderByArm).each!(r => deb(r[0], " / ", r[1]));

      output ~= moves;
      robot.takeOrders();

      zip(robot.arms, robot.orderByArm).each!(r => deb(r[0], " / ", r[1]));
      bool working;
      foreach(arm, order; zip(robot.arms, robot.orderByArm)) {
        if (arm.picked || order !is null) working = true;
      }
      if (!working) break;
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

int[][] basePacks(int base, int size) {
  auto ret = new int[][](base^^size, size);
  foreach(i; 0..base^^size) {
    int x = i;
    foreach(b; 0..size) {
      ret[i][b] = x % base;
      x /= base;
    }
  }
  return ret;
}
