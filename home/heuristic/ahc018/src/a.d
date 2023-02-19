void main() { runSolver(); }

// ----------------------------------------------

void problem() {
  enum INF = int.max / 3;
  enum COST_MIN = 10;
  enum COST_MAX = 5000;
  enum POWER_MAX = 5000;
  enum N = 200;

  enum DIRS = zip([0, 1, 2, 3], [-1, 0, 1, 0], [0, -1, 0, 1]);
  enum DIRS_ARR = zip([0, 1, 2, 3], [-1, 0, 1, 0], [0, -1, 0, 1]).array;

  enum POWERS_ARR = [
    [272, 460, 151, 268, 174, 275, 153, 316, 340, 373, 71, 130, 168, 258, 259, 633, 104, 370, 225], // C = 1, cost = 11807342041331
    [140, 161, 148, 260, 187, 366, 93, 214, 271, 165, 218, 364, 97, 147, 60, 121, 212, 447, 394, 790, 145], // C = 2, cost = 11807134932636
    [432, 18, 333, 104, 286, 27, 166, 376, 151, 129, 388, 203, 109, 266, 267, 199, 190, 311, 307, 211, 527], // C = 4, cost = 13117907878667
    [255, 252, 380, 250, 244, 210, 38, 39, 292, 54, 373, 344, 406, 235, 662, 597, 369], // C = 8, cost = 15357974426220
    [358, 176, 130, 281, 274, 143, 220, 349, 193, 466, 182, 547, 143, 222, 303, 255, 758], // C = 16, cost = 18618405784988
    [388, 363, 329, 240, 396, 268, 211, 543, 294, 352, 138, 398, 410, 670], // C = 32, cost = 24490263086455
    [480, 422, 457, 404, 366, 410, 449, 373, 348, 597, 456, 238], // C = 64, cost = 33971655344755
    [661, 572, 497, 611, 502, 479, 346, 386, 369, 577], // C = 128, cost = 49421868289711
  ];

  struct Coord {
    int x, y, cost;

    this(int x, int y, int cost) {
      this(x, y); this.cost = cost;
    }
    this(int x, int y) {
      this.x = x; this.y = y;
    }
  }

  struct Calculation {
    Coord from;
    int[N][N] costs;
    int[N][N] froms;

    Coord[] bestRoute(bool[N][N] ex) {
      int best = int.max;
      Coord bestCoord;

      foreach(y; 0..N) foreach(x; 0..N) {
        if (!ex[y][x]) continue;

        if (best.chmin(costs[y][x])) {
          bestCoord = Coord(x, y);
        }
      }

      return route(bestCoord);
    }

    Coord[] route(Coord to) {
      Coord[] ret;

      int y = to.y;
      int x = to.x;
      while (froms[y][x] != -1) {
        ret ~= Coord(x, y);
        const d = froms[y][x];
        x -= DIRS_ARR[d][1];
        y -= DIRS_ARR[d][2];
      }

      ret ~= from;
      return ret;
    }
  }

  scan!int; // N = 200
  auto W = scan!int;
  auto K = scan!int;
  auto C = scan!int;
  const WK = W + K;
  auto G = scan!int(2 * WK).chunks(2).map!(c => Coord(c[1], c[0])).array;
  int[] POWERS; {
    for(int i = 0; i < 8; i++) if (C == 2^^i) POWERS = POWERS_ARR[i];
  }

  class State {
    bool[N][N] excavated;
    bool finished;
    int totalCost;

    int[N][N] assumedCosts;
    int[N][N] currentCosts;
    Calculation[] calced;

    this() {
      foreach(i; 0..N * N) {
        const c = uniform(COST_MIN * 6, COST_MAX / 3 + 1);
        assumedCosts[i / N][i % N] = c;
        currentCosts[i / N][i % N] = c;
      }

      foreach(i; 0..G.length) {
        calced ~= calcCostsFrom(G[i]);
      }
    }

    Calculation calcCostsFrom(Coord from, Coord[] exd = []) {
      const fromX = from.x;
      const fromY = from.y;

      foreach(c; exd) currentCosts[c.y][c.x] = 0;

      int[N][N] costs;
      int[N][N] froms;
      foreach(ref c; costs) c[] = INF;
      foreach(ref c; froms) c[] = -1;
      costs[fromY][fromX] = 0;

      for (auto queue = [Coord(fromX, fromY, 0)].heapify!"a.cost > b.cost"; !queue.empty;) {
        auto p = queue.front; queue.removeFront;
        if (costs[p.y][p.x] != p.cost) continue;

        static foreach(dir, dx, dy; DIRS) {{
          const x = p.x + dx;
          const y = p.y + dy;
          if (min(x, y) >= 0 && max(x, y) < N) {
            if (costs[y][x].chmin(p.cost + assumedCosts[y][x])) {
              froms[y][x] = dir;
              queue.insert(Coord(x, y, costs[y][x]));
            }
          }
        }}
      }

      foreach(c; exd) currentCosts[c.y][c.x] = assumedCosts[c.y][c.x];
      return Calculation(from, costs, froms);
    }

    int excavate(Coord p) {
      const x = p.x;
      const y = p.y;
      if (excavated[y][x]) return 0;

      assumedCosts[y][x] = 0;
      currentCosts[y][x] = 0;
      excavated[y][x] = true;

      int sum;
      foreach(power; POWERS) {
        sum += power;
        writefln("%s %s %s", y, x, power);
        stdout.flush;

        const r = scan!int;
        if (r == 2) finished = true;
        if (r >= 1) return sum;
        if (r != 0) assert(false, "bad request");
      }
      return 0;
    }
  }

  auto solve() {
    auto state = new State();
    auto costs = new int[][](2 ^^ WK, WK);
    auto routes = new int[][][](2 ^^ WK, WK, 0);
    foreach(ref s; costs) s[] = INF;
    foreach(st; 0..WK) {
      costs[2 ^^ st][st] = state.assumedCosts[G[st].y][G[st].x];
      routes[2 ^^ st][st] ~= st;
    }

    const satisfy = iota(W, W + K).map!"2 ^^ a".sum;

    int bestCost = INF;
    int[] bestRoute;
    foreach(fromState; 1..2 ^^ WK) {
      foreach(from; 0..WK) {
        if ((fromState & (2^^from)) == 0) continue;

        foreach(to; 0..WK) {
          if ((fromState & (2^^to)) != 0) continue;

          const toState = fromState | (2^^to);
          const cost = costs[fromState][from] + state.calced[from].costs[G[to].y][G[to].x];
          costs[toState][to].chmin(cost);
          routes[toState][to] = routes[fromState][from] ~ to;

          if (toState > satisfy && bestCost.chmin(cost)) {
            bestRoute = routes[toState][to];
          }
        }
      }
    }

    int from = bestRoute[0];
    state.excavate(G[from]);
    foreach(to; bestRoute[1..$]) {
      auto calc = state.calcCostsFrom(G[to]);
      foreach(p; calc.bestRoute(state.excavated)) {
        state.excavate(p);
      }
      from = to;
    }
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
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
  enum BORDER = "#==================================";
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; break; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
