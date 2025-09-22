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

  struct Coord {
    int r, c;

    T of(T)(T[][] matrix) {
      return matrix[r][c];
    }

    int asId() {
      return r * 50 + c;
    }

    bool valid() {
      return min(r, c) >= 0 && max(r, c) < N;
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
  }

  Coord GOAL = Coord(TR, TC);
  Coord START = Coord(0, N / 2);

  auto reachable2(Coord start, bool[][] blocked, Coord add) {
    bool[][] visited = new bool[][](N, N);
    visited[start.r][start.c] = true;
    int visits;
    
    for (auto queue = DList!Coord([start]); !queue.empty;) {
      auto cur = queue.front;
      queue.removeFront;
      visits++;
      
      foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
        auto r = dr + cur.r;
        auto c = dc + cur.c;
        if (min(r, c) < 0 || max(r, c) >= N) continue;
        if (visited[r][c] || blocked[r][c] || Coord(r, c) == add) continue;

        visited[r][c] = true;
        queue.insertBack(Coord(r, c));
      }
    }
    return tuple(GOAL.of(visited), visits);
  }
  auto reachable(Coord start, bool[][] blocked) {
    return reachable2(start, blocked, Coord(-1, -1));
  }

  Coord[] aroundDist(Coord base, int distance) {
    Coord[] ret;
    foreach(r; iota(-distance, distance + 1)) {
      auto c = distance - abs(r);
      ret ~= Coord(base.r + r, base.c + c);
      if (c > 0) ret ~= Coord(base.r + r, base.c - c);
    }
    return ret.filter!(c => c.valid).array;
  }

  Coord[] crossLine(Coord base, int offset) {
    Coord[] ret;
    auto br = base.r + offset;
    auto bc = base.c;

    ret ~= Coord(br, bc);
    foreach(d; 1..N) {
      ret ~= Coord(br - d, bc - d);
      ret ~= Coord(br + d, bc + d);
    }

    return ret.filter!(c => c.valid).array;
  }

  bool[][] visited = new bool[][](N, N);
  bool[][] blocked = new bool[][](N, N);
  foreach (r; 0..N) foreach (c; 0..N) blocked[r][c] = G[r][c] == 'T';
  blocked[START.r][START.c] = true;

  Coord[] blocksToAdd = {
    Coord[] ret;
    auto baseBlocked = blocked.map!"a.dup".array;

    int step;
    foreach(d; iota(-1 - ((N + 2) / 3) * 6, N * 2, 3)) {
      auto toBlock = crossLine(GOAL, d);

      foreach(coord; d % 2 == 0 ? toBlock.sort!"a.r < b.r".array : toBlock.sort!"a.r > b.r".array) {
        // auto preEval = reachable(START, baseBlocked);
        // auto postEval = reachable2(START, baseBlocked, coord);
        // coord.deb;
        // [preEval, postEval].deb;
        // if (preEval[1] == postEval[1] + 1 || preEval[1] == postEval[1]) {
          ret ~= coord;
          // baseBlocked[coord.r][coord.c] = true;
        // }
      }
      step++;
    }
    return ret.filter!(coord => !coord.of(blocked)).array;

    // foreach(d; iota(1, N * 2, 4)) {
    //   auto toBlock = aroundDist(GOAL, d);
    //   if (toBlock.empty) continue;

    //   REM: foreach(rem; 1..min(toBlock.length + 1, N)) {
    //     foreach(_; 0..10) {
    //       auto testBlocked = baseBlocked.map!"a.dup".array;
    //       auto candidates = toBlock.randomSample(toBlock.length - rem, RND).array;
    //       if (d == 1) {
    //         candidates = toBlock.sort!((a, b) => a.dist(START) < b.dist(START)).array[0..$ - 1];
    //       }
    //       foreach(coord; candidates) testBlocked[coord.r][coord.c] = true;

    //       auto eval = reachable(START, testBlocked);
    //       if (eval[0]) {
    //         foreach(coord; candidates) {
    //           if (!baseBlocked[coord.r][coord.c]) ret ~= coord;
    //           baseBlocked[coord.r][coord.c] = true;
    //         }
    //         break REM;
    //       }
    //     }
    //   }
    // }

    // // 作った格子状の木のうち、全体の連結性を向上させるものはやめる
    // Coord[] filtered;
    // foreach(b; ret) {
    //   auto preEval = reachable(START, baseBlocked);
    //   auto testBlocked = baseBlocked.map!"a.dup".array;
    //   testBlocked[b.r][b.c] = false;

    //   auto eval = reachable(START, testBlocked);
    //   if (preEval[1] < eval[1] - 5) {
    //     baseBlocked[b.r][b.c] = false;
    //   } else {
    //     filtered ~= b;
    //   }
    // }
    // return filtered;
  }();

  // foreach(b; blocksToAdd) blocked[b.r][b.c] = true;
  // blocksToAdd.multiSort!("a.r < b.r", "a.c < b.c").deb;
  auto candidates = blocksToAdd.redBlackTree;
  candidates.insert(Coord(GOAL.r - 1, GOAL.c));
  candidates.insert(Coord(GOAL.r + 1, GOAL.c));
  candidates.insert(Coord(GOAL.r, GOAL.c - 1));
  candidates.insert(Coord(GOAL.r, GOAL.c + 1));
  // blocked[START.r][START.c] = true;

  // candidates.deb;
  blocksToAdd.length = 0;
  Coord[] nexts = [Coord(0, N / 2)];

  foreach (turn; 0..int.max) {
    Coord from = Coord(scan!int, scan!int);
    foreach (r, c; scan!int(scan!int * 2).chunks(2).asTuples!2) visited[r][c] = true;
    if (from == GOAL) break;

    foreach(next; nexts) {
      foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1]).array.randomShuffle(RND).asTuples!2) {
        foreach(d; 1..N) {
          auto coord = Coord(next.r + dr*d, next.c + dc*d);

          if (!coord.valid || coord.of(blocked)) break;
          if (coord.of(visited) || !(coord in candidates)) continue;

          if (coord.dist(GOAL) > 2 && uniform(0, 20, RND) < 2) continue;

          auto preEval = reachable(from, blocked);
          auto postEval = reachable2(from, blocked, coord);
          coord.deb;
          [preEval, postEval].deb;
          
          if (preEval[1] - 1 == postEval[1]) {
            blocksToAdd ~= coord;
            blocked[coord.r][coord.c] = true;
            candidates.removeKey(coord);
            break;
          }
        }
      }
    }

    writefln("%s %(%s %)", blocksToAdd.length, blocksToAdd.map!"a.asArray".joiner);
    stdout.flush();
    blocksToAdd.length = 0;

    nexts.length = 0;
    foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
      auto r = dr + from.r;
      auto c = dc + from.c;
      if (min(r, c) < 0 || max(r, c) >= N|| blocked[r][c]) continue;
      
      nexts ~= Coord(r, c);
    }
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

// -----------------------------------------------

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}
