void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum int INF = int.max / 3;

  int N = scan!int;
  int TR = scan!int;
  int TC = scan!int;
  dchar[][] G = scan!string(N).map!"a.array".array;

  auto IDEAL_GOAL_AROUND = {
    int[][][] ret;
    auto base = [
      [9,9,9,9,9,9,9,9,9],
      [9,9,9,0,9,9,9,9,9],
      [9,9,0,0,1,1,1,9,9],
      [9,1,0,1,0,0,0,1,9],
      [9,1,0,1,0,1,0,1,9],
      [9,1,0,0,1,0,0,1,9],
      [9,9,1,0,0,0,1,9,9],
      [9,9,9,1,1,1,9,9,9],
      [9,9,9,9,9,9,9,9,9],
    ];
    ret ~= base;
    foreach(_; 0..3) ret ~= rotate(ret.back);
    ret ~= mirrorX(base);
    foreach(_; 0..3) ret ~= rotate(ret.back);

    auto base2 = [
      [9,9,9,9,9,1,9,9,9],
      [9,9,9,9,0,0,0,9,9],
      [9,9,9,0,1,0,9,0,9],
      [9,9,9,1,0,0,0,0,1],
      [9,9,9,1,0,1,0,9,9],
      [9,9,9,0,1,0,9,9,9],
      [9,9,9,9,9,9,9,9,9],
      [9,9,9,9,9,9,9,9,9],
      [9,9,9,9,9,9,9,9,9],
    ];
    ret ~= base2;
    foreach(_; 0..3) ret ~= rotate(ret.back);
    ret ~= mirrorX(base2);
    foreach(_; 0..3) ret ~= rotate(ret.back);
    
    return ret;
  }();

  struct Coord {
    int r, c;

    T of(T)(T[][] matrix) {
      return matrix[r][c];
    }

    int id() {
      return r * N + c;
    }

    bool valid() {
      return min() >= 0 && max() < N;
    }

    int[] asArray() {
      return [r, c];
    }

    int dist(Coord other) {
      return abs(r - other.r) + abs(c - other.c);
    }

    inout int opCmp(inout Coord other) {
      return cmp([r, c], [other.r, other.c]);
    }

    int min() { return .min(r, c); }
    int max() { return .max(r, c); }
  }

  Coord[][int] memoCoordAround;
  Coord[] around(Coord coord) {
    auto id = coord.id;
    if (id in memoCoordAround) return memoCoordAround[id];

    Coord[] ret;
    foreach(dr, dc; zip([-1, 1, 0, 0], [0, 0, -1, 1])) {
      auto t = Coord(coord.r + dr, coord.c + dc);
      if (t.valid) ret ~= t;
    }
    return memoCoordAround[id] = ret;
  }

  Coord GOAL = Coord(TR, TC);
  Coord START = Coord(0, N / 2);
  Coord[][] RANDOM_COORDS;

  Coord[] crossLine(Coord base, int offset, int dir = 0) {
    Coord[] ret;
    auto br = base.r + offset;
    auto bc = base.c;

    ret ~= Coord(br, bc);
    if (dir == 0) {
      foreach(d; 1..N) {
        ret ~= Coord(br + d, bc - d);
        ret ~= Coord(br - d, bc + d);
      }
    } else {
      foreach(d; 1..N) {
        ret ~= Coord(br - d, bc - d);
        ret ~= Coord(br + d, bc + d);
      }
    }
    return ret.filter!(c => c.valid).array;
  }

  class Simulator {
    BitArray visited;
    BitArray revealed;
    BitArray blocked;
    BitArray prohibitBlock;
    bool dryRun;
    int simId;

    long turn;
    Coord[] nexts;
    Coord[] blocksToAdd, priorBlock;
    RedBlackTree!Coord candidates;

    Coord playerCoord;
    BitArray playersVisited;
    DList!Coord playersQueue;
    int[] distances;

    this(int simId) {
      this.simId = simId;
      visited = BitArray(false.repeat(N^^2).array);
      revealed = BitArray(false.repeat(N^^2).array);
      revealed[START.id] = true;
      prohibitBlock = BitArray(false.repeat(N^^2).array);
      prohibitBlock[START.id] = true;
      nexts = [START];
      
      blocked = BitArray(false.repeat(N^^2).array);
      foreach (r; 0..N) foreach (c; 0..N) blocked[r * N + c] = G[r][c] == 'T';

      playerCoord = START;
      playersVisited = BitArray(false.repeat(N^^2).array);
      playersQueue = DList!Coord(RANDOM_COORDS[simId % $]);
    }
    this(bool dry, Coord[] candidatesArray, int simId = 0) {
      this(simId);
      dryRun = dry;
      candidates = candidatesArray.redBlackTree;
    }

    auto reachable(Coord start) {
      return reachable(start, Coord(-1, -1), blocked);
    }
    auto reachable(Coord start, Coord add) {
      return reachable(start, add, blocked);
    }
    auto reachable(Coord start, BitArray testMap) {
      return reachable(start, Coord(-1, -1), testMap);
    }
    auto reachable(Coord start, Coord add, BitArray testMap) {
      BitArray v = BitArray(false.repeat(N^^2).array);
      v[start.id] = true;
      int visits;
      
      for (auto queue = DList!Coord([start]); !queue.empty;) {
        auto cur = queue.front;
        queue.removeFront;
        visits++;
        
        foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
          auto coord = Coord(dr + cur.r, dc + cur.c);

          if (!coord.valid) continue;
          if (v[coord.id] || testMap[coord.id] || coord == add) continue;

          v[coord.id] = true;
          queue.insertBack(coord);
        }
      }
      return tuple(v[GOAL.id], visits);
    }

    int scoreForAroundGoalMatirx(int[][] matrix) {
      auto size = matrix.length.to!int;
      auto half = size / 2;
      int ret;
      int score_base = 2^^24;

      auto testBlocked = blocked.dup;
      foreach(r; 0..size) foreach(c; 0..size) {
        if (matrix[r][c] == 9) continue;

        auto coord = Coord(r + GOAL.r - half, c + GOAL.c - half);
        auto block = coord.valid ? blocked[coord.id] : false;
        auto dist = coord.dist(GOAL) + 1;

        if (matrix[r][c] == 0 && !block) {
          ret += score_base / 2^^dist;
        }
        if (matrix[r][c] == 1) {
          if (block) ret += score_base / 2^^dist / 4;
          else if (coord == START) return 1;

          if (coord.valid) testBlocked[coord.id] = true;
        }
      }

      return reachable(START, testBlocked)[0] ? ret : 0;
    }

    void applyAroundGoalMatrix(int[][] matrix) {
      auto size = matrix.length.to!int;
      auto half = size / 2;
      foreach(r; 0..size) foreach(c; 0..size) {
        if (matrix[r][c] == 9) continue;

        auto coord = Coord(r + GOAL.r - half, c + GOAL.c - half);
        if (!coord.valid) continue;

        if (matrix[r][c] == 0) prohibitBlock[coord.id] = true;
        if (matrix[r][c] == 1 && !blocked[coord.id] && !prohibitBlock[coord.id]) priorBlock ~= coord;
      }
    }

    int[] calcDistances(Coord to) {
      // debf("calculate distance from: %s", to);
      auto pb = revealed & blocked;
      auto ret = INF.repeat(N^^2).array;
      if (pb[to.id]) return ret;

      ret[to.id] = 0;

      for(auto queue = DList!Coord([to]); !queue.empty;) {
        auto cur = queue.front;
        queue.removeFront();

        auto nr = ret[cur.id] + 1;
        foreach(next; around(cur)) {
          if (pb[next.id] || ret[next.id] <= nr) continue;

          ret[next.id] = nr;
          queue.insertBack(next);
        }
      }

      return ret;
    }

    Coord[] simulatePlayerLookAround() {
      auto to = playerCoord;
      if (playersVisited[to.id]) return [];
      playersVisited[to.id] = true;

      Coord[] ret;
      foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
        foreach(d; 1..N) {
          auto coord = Coord(to.r + dr*d, to.c + dc*d);
          if (!coord.valid) break;

          if (!revealed[coord.id]) {
            revealed[coord.id] = true;
            ret ~= coord;
          }
          if (blocked[coord.id]) break;
        }
      }

      if (!ret.empty) {
        distances = calcDistances(playersQueue.front);
      }
      return ret;
    }

    Coord simulatePlayerNext() {
      if (turn == 0) return START;
      if (playersQueue.empty) return GOAL;

      auto target = playersQueue.front;
      
      if (revealed[GOAL.id]) {
        if (target != GOAL) playersQueue.insertFront(GOAL);
      } else {
        while(!playersQueue.empty && (revealed[playersQueue.front.id] || distances[playerCoord.id] == INF)) {
          playersQueue.removeFront();
          if (playersQueue.empty) return GOAL;

          target = playersQueue.front;
          distances = calcDistances(target);
          // deb(playerCoord, target, [], revealed[target.id], [], distances[playerCoord.id]);
        }
        if (playersQueue.empty) return GOAL;
      }

      if (target != playersQueue.front) {
        target = playersQueue.front;
        distances = calcDistances(target);
      }

      int dist = INF;
      Coord nextTo;
      foreach(next; around(playerCoord)) {
        if (dist.chmin(distances[next.id])) nextTo = next;
      }
      // debf("turn = %s, target = %s, player = %s, next = %s", turn, target, playerCoord, nextTo);
      // deb([revealed[nextTo.id], blocked[nextTo.id]]);
      playerCoord = nextTo;
      return nextTo;
    }

    bool walk(Coord from, Coord[] seen) {
      assert(!blocked[from.id], "Invalid move to " ~ from.to!string);

      foreach (s; seen) revealed[s.id] = true;
      if (from == GOAL) return true;

      visited[from.id] = true;

      if (turn == 0) {
        foreach(coord; priorBlock.sort!((a, b) => a.dist(START) < b.dist(START))) {
          auto eval = reachable(START, coord);
          if (eval[0]) {
            blocksToAdd ~= coord;
            blocked[coord.id] = true;
            candidates.removeKey(coord);
            // debf("blocked to: %s (prior)", coord);
          }
        }
      }

      turn++;
      foreach(next; nexts) {
        foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
          foreach(d; 1..N) {
            auto coord = Coord(next.r + dr*d, next.c + dc*d);

            if (!coord.valid || blocked[coord.id]) break;
            if (revealed[coord.id] || prohibitBlock[coord.id] || !(coord in candidates)) continue;

            auto preEval = reachable(from);
            auto postEval = reachable(from, coord);
            // deb(coord, [preEval, postEval]);
            
            if (preEval[1] - 1 == postEval[1]) {
              blocksToAdd ~= coord;
              blocked[coord.id] = true;
              candidates.removeKey(coord);
              // debf("blocked to: %s", coord);
              break;
            }
          }
        }
      }

      if (!dryRun) {
        writefln("%s %(%s %)", blocksToAdd.length, blocksToAdd.map!"a.asArray".joiner);
        stdout.flush();
      }

      blocksToAdd.length = 0;
      nexts.length = 0;
      foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
        auto coord = Coord(dr + from.r, dc + from.c);
        if (!coord.valid || blocked[coord.id]) continue;
        
        nexts ~= coord;
      }
      return false;
    }
  }

  enum RANDOM_COORDS_SIZE = 50;
  RANDOM_COORDS = iota(RANDOM_COORDS_SIZE).map!(_ => START ~ cartesianProduct(N.iota, N.iota).array.randomShuffle(RND).map!(a => Coord(a[0], a[1])).array).array;

  enum TEST_WIDTH = 2;
  auto aroundGoalMatrixIndicies = {
    int score(long id) {
      auto sim = new Simulator(true, []);
      return sim.scoreForAroundGoalMatirx(IDEAL_GOAL_AROUND[id]);
    }
    return iota(IDEAL_GOAL_AROUND.length.to!int).array.sort!((a, b) => score(a) > score(b)).array;
  }()[0..min($, TEST_WIDTH)];
  auto realWidth = aroundGoalMatrixIndicies.length.to!int;

  auto mazes = iota(2).map!((dir) {
    bool[][] blocked = new bool[][](N, N);
    foreach (r; 0..N) foreach (c; 0..N) blocked[r][c] = G[r][c] == 'T';

    Coord[] ret;
    foreach(d; iota(-1 - ((N + 2) / 3) * 6, N * 2, 3)) {
      foreach(coord; crossLine(GOAL, d, dir)) ret ~= coord;
    }
    return ret.filter!(coord => !coord.of(blocked)).array;
  }).array;

  int[][] scores = new int[][](2 * realWidth, 1);
  while(!elapsed(1500)) {
    foreach(random; 0..RANDOM_COORDS_SIZE) {
      if (elapsed(1400)) break;

      foreach(matrixId, matrixIndex; aroundGoalMatrixIndicies.enumerate(0)) {
        auto matrix = IDEAL_GOAL_AROUND[matrixIndex];

        foreach(mazeId, maze; mazes.enumerate(0)) {
          auto id = matrixId * 2 + mazeId;

          auto sim = new Simulator(true, maze, random);
          if (sim.scoreForAroundGoalMatirx(matrix) == -1) {
            scores[id] ~= 1;
          } else {
            sim.applyAroundGoalMatrix(matrix);
            while(true) {
              Coord[] revealed = sim.simulatePlayerLookAround();
              auto next = sim.simulatePlayerNext();

              if (sim.walk(next, revealed)) break;
            }
            scores[id] ~= sim.turn.to!int;
          }
        }
      }
    }
    break;
  }

  debf("tested: %s", scores[0].length);
  scores.each!sort;
  scores.each!deb;

  int bestScore, bestMatrixId, bestMazeId;
  foreach(mazeId; 0..2) foreach(matrixId; 0..realWidth) {
    auto id = matrixId * 2 + mazeId;
    auto score = scores[id].sum;
    if (bestScore.chmax(score)) {
      bestMatrixId = aroundGoalMatrixIndicies[matrixId];
      bestMazeId = mazeId;
    }
  }
  debf("best Id: %s", aroundGoalMatrixIndicies.countUntil(bestMatrixId) * 2 + bestMazeId);

  Simulator sim = new Simulator(false, mazes[bestMazeId]);
  sim.applyAroundGoalMatrix(IDEAL_GOAL_AROUND[bestMatrixId]);
  while(true) {
    Coord from = Coord(scan!int, scan!int);
    Coord[] revealed = scan!int(scan!int * 2).chunks(2).map!(a => Coord(a[0], a[1])).array;

    if (sim.walk(from, revealed)) break;
  }
}

// ----------------------------------------------

import std;
import core.bitop;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(lazy T t){ debug { stderr.write("# "); stderr.writeln(t); }}
void debf(T ...)(lazy T t){ debug { stderr.write("# "); stderr.writefln(t); }}
T[] divisors(T)(T n) { T[] ret; for (T i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == float) || is(T == double) || is(T == float)) "%.16f".writefln(fn());
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

auto mirrorX(T)(T[][] matrix) {
  auto size = matrix.length;
  return iota(size).map!(r => iota(size).map!(c => matrix[r][size - 1 - c]).array).array;
}
auto rotate(T)(T[][] matrix) {
  auto size = matrix.length;
  return iota(size).map!(r => iota(size).map!(c => matrix[c][size - 1 - r]).array).array;
}

// -----------------------------------------------

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}
