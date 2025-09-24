void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int TR = scan!int;
  int TC = scan!int;
  dchar[][] G = scan!string(N).map!"a.array".array;

  auto IDEAL_GOAL_AROUND = {
    auto base = [
      [9,9,9,9,0,9,9],
      [9,9,9,1,0,9,9],
      [9,9,1,0,0,0,9],
      [9,9,1,0,1,9,9],
      [9,9,9,1,9,9,9],
      [9,9,9,9,9,9,9],
      [9,9,9,9,9,9,9],
    ];
    auto base1 = rotate(base);
    auto base2 = rotate(base1);
    auto base3 = rotate(base2);
    auto mirror = mirrorX(base);
    auto mirror1 = rotate(mirror);
    auto mirror2 = rotate(mirror1);
    auto mirror3 = rotate(mirror2);
    return [base, base1, base2, base3, mirror, mirror1, mirror2, mirror3];
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

  Coord GOAL = Coord(TR, TC);
  Coord START = Coord(0, N / 2);

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
    bool dryRun;

    long turn;
    Coord[] nexts;
    Coord[] blocksToAdd, priorBlock;
    RedBlackTree!Coord candidates;

    BitArray playersMemo;
    DList!Coord playersQueue;

    this() {
      visited = BitArray(false.repeat(N^^2).array);
      revealed = BitArray(false.repeat(N^^2).array);
      revealed[START.id] = true;
      
      blocked = BitArray(false.repeat(N^^2).array);
      foreach (r; 0..N) foreach (c; 0..N) blocked[r * N + c] = G[r][c] == 'T';

      playersMemo = BitArray(false.repeat(N^^2).array);
      playersMemo[START.id] = true;
      playersQueue = DList!Coord([START]);
    }
    this(bool dry, Coord[] candidatesArray) {
      this();
      nexts = [START];
      dryRun = dry;
      candidates = candidatesArray.redBlackTree;
    }

    auto reachable(Coord start) {
      return reachable(start, Coord(-1, -1));
    }
    auto reachable(Coord start, Coord add) {
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
          if (v[coord.id] || blocked[coord.id] || coord == add) continue;

          v[coord.id] = true;
          queue.insertBack(coord);
        }
      }
      return tuple(v[GOAL.id], visits);
    }

    int scoreForAroundGoalMatirx(int[][] matrix) {
      int ret;
      int score_base = 65536;
      foreach(r; 0..7) foreach(c; 0..7) {
        if (matrix[r][c] == 9) continue;

        auto coord = Coord(r + GOAL.r - 3, c + GOAL.c - 3);
        auto block = coord.valid ? blocked[coord.id] : false;
        auto dist = coord.dist(GOAL) + 1;

        if (matrix[r][c] == 0 && !block) {
          ret += START.dist(coord)^^4;
          ret += score_base / 4^^dist;
        }
        if (matrix[r][c] == 1 && block) ret += score_base / 4^^dist / 4;
      }
      return ret;
    }

    void applyAroundGoalMatrix(int[][] matrix) {
      foreach(r; 0..7) foreach(c; 0..7) {
        if (matrix[r][c] == 9) continue;

        auto coord = Coord(r + GOAL.r - 3, c + GOAL.c - 3);
        if (!coord.valid) continue;

        if (matrix[r][c] == 0) revealed[coord.id] = true;
        if (matrix[r][c] == 1 && !blocked[coord.id]) priorBlock ~= coord;
      }
    }

    Coord[] simulatePlayerWalked(Coord from) {
      foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
        auto coord = Coord(from.r + dr, from.c + dc);
        if (!coord.valid || visited[coord.id] || blocked[coord.id]) continue;
        
        playersQueue.insertBack(coord);
      }

      if (turn == 0) return [START];

      Coord[] ret;
      if (!revealed[from.id]) ret ~= from;

      foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
        foreach(d; 1..N) {
          auto coord = Coord(from.r + dr*d, from.c + dc*d);
          if (!coord.valid) break;

          if (!revealed[coord.id]) ret ~= coord;
          if (blocked[coord.id]) break;
        }
      }

      foreach(c; ret) playersMemo[c.id] = true;

      return ret;
    }

    Coord simulatePlayerNext() {
      while(!playersQueue.empty) {
        auto cur = playersQueue.front;
        playersQueue.removeFront();

        if (visited[cur.id]) continue;
        return cur;
      }

      return GOAL;
    }

    bool walk(Coord from, Coord[] seen) {
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
          }
        }
      }

      turn++;
      foreach(next; nexts) {
        foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
          foreach(d; 1..N) {
            auto coord = Coord(next.r + dr*d, next.c + dc*d);

            if (!coord.valid || blocked[coord.id]) break;
            if (revealed[coord.id] || !(coord in candidates)) continue;

            if (coord.dist(GOAL) < 8) {
              if (uniform(0, 20, RND) < 3) continue;
              // if (uniform(0, 20, RND) < 10 && (coord.min == 0 || coord.max == N - 1)) continue;
            }

            if (coord.dist(START) < 4) {
              if (uniform(0, 20, RND) < 15) continue;
              // if (uniform(0, 20, RND) < 10 && (coord.min == 0 || coord.max == N - 1)) continue;
            }

            auto preEval = reachable(from);
            auto postEval = reachable(from, coord);
            // deb(coord, [preEval, postEval]);
            
            if (preEval[1] - 1 == postEval[1]) {
              blocksToAdd ~= coord;
              blocked[coord.id] = true;
              candidates.removeKey(coord);
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

  G[START.r][START.c] = 'T';
  bool[][] blocked = new bool[][](N, N);
  foreach (r; 0..N) foreach (c; 0..N) blocked[r][c] = G[r][c] == 'T';

  Coord[] blocksToAdd1 = {
    Coord[] ret;
    foreach(d; iota(-1 - ((N + 2) / 3) * 6, N * 2, 3)) {
      foreach(coord; crossLine(GOAL, d, 0)) ret ~= coord;
    }
    return ret.filter!(coord => !coord.of(blocked)).array;
  }();
  Coord[] blocksToAdd2 = {
    Coord[] ret;
    foreach(d; iota(-1 - ((N + 2) / 3) * 6, N * 2, 3)) {
      foreach(coord; crossLine(GOAL, d, 1)) ret ~= coord;
    }
    return ret.filter!(coord => !coord.of(blocked)).array;
  }();
  auto candidates1 = blocksToAdd1.redBlackTree;
  auto candidates2 = blocksToAdd2.redBlackTree;
  foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
    candidates1.insert(Coord(GOAL.r + dr, GOAL.c + dc));
    candidates2.insert(Coord(GOAL.r + dr, GOAL.c + dc));
  }

  auto aroundGoalMatrix = {
    auto sim = new Simulator(true, []);
    int bestScore;
    long bestMatrixId;

    foreach(i, matrix; IDEAL_GOAL_AROUND) {
      if (bestScore.chmax(sim.scoreForAroundGoalMatirx(matrix))) {
        bestMatrixId = i;
      }
    }
    return IDEAL_GOAL_AROUND[bestMatrixId];
  }();

  Simulator dSim1 = new Simulator(true, candidates1.array);
  dSim1.applyAroundGoalMatrix(aroundGoalMatrix);
  while(true) {
    auto from = dSim1.simulatePlayerNext();
    Coord[] revealed = dSim1.simulatePlayerWalked(from);

    if (dSim1.walk(from, revealed)) break;
  }
  dSim1.turn.deb;

  Simulator dSim2 = new Simulator(true, candidates2.array);
  dSim2.applyAroundGoalMatrix(aroundGoalMatrix);
  while(true) {
    auto from = dSim2.simulatePlayerNext();
    Coord[] revealed = dSim2.simulatePlayerWalked(from);

    if (dSim2.walk(from, revealed)) break;
  }
  dSim2.turn.deb;

  Simulator sim = new Simulator(false, dSim1.turn >= dSim2.turn ? candidates1.array : candidates2.array);
  sim.applyAroundGoalMatrix(aroundGoalMatrix);
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
