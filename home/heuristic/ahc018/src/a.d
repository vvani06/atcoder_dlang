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
    [23, 42, 105, 139, 186, 190, 202, 356, 361, 402, 489, 558, 577, 614, 617, 139], // C = 1, cost = 6899160871
    [38, 50, 119, 181, 192, 202, 325, 399, 399, 447, 559, 617, 624, 624, 224], // C = 2, cost = 7461997509
    [65, 86, 86, 131, 209, 281, 380, 387, 452, 529, 540, 544, 570, 588, 152], // C = 4, cost = 8134445713
    [62, 150, 158, 162, 190, 295, 363, 388, 392, 397, 511, 511, 582, 600, 239], // C = 8, cost = 9147861768
    [68, 122, 197, 203, 265, 317, 344, 399, 509, 520, 555, 588, 622, 291], // C = 16, cost = 11458472194
    [58, 119, 192, 320, 327, 376, 385, 412, 434, 441, 519, 520, 576, 321], // C = 32, cost = 15503365249
    [134, 301, 367, 395, 423, 482, 485, 487, 487, 502, 548, 389], // C = 64, cost = 22348091897
    [180, 391, 561, 594, 598, 599, 604, 604, 605, 264], // C = 128, cost = 33678770018
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
      Coord[] mountains;
      foreach(i; 0..WK - 2) foreach(j; i + 1..WK - 1) foreach(k; j + 1..WK) {
        int x = (G[i].x + G[j].x + G[k].x) / 3;
        int y = (G[i].y + G[j].y + G[k].y) / 3;
        mountains ~= Coord(x, y);
      }

      int[N][N] rate;
      int rmin = int.max;
      int rmax = int.min;
      foreach(x; 0..N) foreach(y; 0..N) {
        foreach(m; mountains) {
          auto d = abs(m.x - x) + abs(m.y - y);
          rate[y][x] += max(0, 5 - d);
        }
        foreach(m; G) {
          auto d = abs(m.x - x) + abs(m.y - y);
          rate[y][x] -= max(0, 25 - d);
        }

        rmax = max(rmax, rate[y][x]);
        rmin = min(rmin, rate[y][x]);
      }
      foreach(i; 0..N * N) {
        int r = rate[i / N][i % N];
        r -= rmin;
        r *= 2000;
        r /= rmax;
        const c = max(10, r);
        assumedCosts[i / N][i % N] = c;
        currentCosts[i / N][i % N] = c;
      }

      assumedCosts.deb;

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
            if (costs[y][x].chmin(p.cost + assumedCosts[y][x] + C)) {
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
      int power = max(10, C);
      while(true) {
        sum += power;
        writefln("%s %s %s", y, x, power);
        stdout.flush;

        const r = scan!int;
        if (r == 2) finished = true;
        if (r >= 1) return sum;
        if (r != 0) assert(false, "bad request");
        power += max(10, C);
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
