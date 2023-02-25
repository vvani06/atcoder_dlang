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
    [31, 37, 104, 145, 183, 200, 327, 353, 364, 386, 415, 455, 542, 561, 561, 336], // C = 1, cost = 6646256620
    [25, 37, 90, 116, 193, 210, 220, 284, 301, 314, 460, 561, 597, 620, 624, 348], // C = 2, cost = 7053647889
    [18, 49, 56, 112, 141, 156, 203, 256, 298, 385, 425, 491, 501, 570, 591, 603, 145], // C = 4, cost = 7612088907
    [59, 114, 130, 208, 252, 278, 284, 321, 325, 380, 397, 441, 522, 577, 602, 110], // C = 8, cost = 8780623755
    [58, 72, 129, 199, 232, 265, 305, 358, 415, 418, 503, 523, 551, 610, 362], // C = 16, cost = 11243337008
    [92, 189, 235, 311, 312, 331, 337, 346, 389, 426, 464, 551, 588, 429], // C = 32, cost = 15313646724
    [128, 228, 337, 460, 463, 471, 479, 500, 509, 511, 527, 387], // C = 64, cost = 22316686856
    [183, 402, 557, 591, 592, 595, 597, 600, 601, 282], // C = 128, cost = 33676810521
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
    Coord from = Coord(-1, -1);
    int[N][N] costs;
    int[N][N] froms;

    Coord bestTarget(bool[N][N] ex) {
      int best = int.max;
      Coord bestCoord;

      foreach(y; 0..N) foreach(x; 0..N) {
        if (!ex[y][x]) continue;

        if (best.chmin(costs[y][x])) {
          bestCoord = Coord(x, y, costs[y][x]);
        }
      }

      return bestCoord;
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
    bool[N][N] tested;

    int[N][N] assumedCosts;
    int[N][N] currentCosts;
    int[N][N] actualCosts;
    Calculation[] calced;

    bool finished;
    int totalCost;

    this() {
      foreach(x; 0..N) foreach(y; 0..N) {
        assumedCosts[y][x] = 2500;
      }

      auto mid = N / WK;
      bool[N][N] toTest;
      bool[N][N] covered;
      foreach(c; G) {
        toTest[c.y][c.x] = true;
        foreach(dy; -mid/2..mid/2) foreach(dx; -mid/2..mid/2) {
          auto cy = c.y + dy;
          auto cx = c.x + dx;
          if (min(cx, cy) < 0 || max(cx, cy) >= N) continue;
          covered[cy][cx] = true;
        }
      }
      foreach(c; G) {
        foreach(y; iota(c.y - mid * 2, c.y + mid * 2, mid)) foreach(x; iota(c.x - mid * 2, c.x + mid * 2, mid)) {
          if (min(x, y) < 0 || max(x, y) >= N || covered[y][x]) continue;
          toTest[y][x] = true;
          foreach(dy; -mid/2..mid/2) foreach(dx; -mid/2..mid/2) {
            auto cy = y + dy;
            auto cx = x + dx;
            if (min(cx, cy) < 0 || max(cx, cy) >= N) continue;
            covered[cy][cx] = true;
          }
        }
      }

      foreach(y; 0..N) foreach(x; 0..N) {
        if (!toTest[y][x]) continue;
        
        auto c = Coord(x, y);
        auto h = excavate(c, true);
        if (h == -1) continue;

        foreach(dy; -mid/2..mid/2) foreach(dx; -mid/2..mid/2) {
          if (min(c.y + dy, c.x + dx) < 0 || max(c.y + dy, c.x + dx) >= N) continue;

          auto r = mid - abs(dy) - abs(dx);
          assumedCosts[c.y + dy][c.x + dx] *= (mid - r);
          assumedCosts[c.y + dy][c.x + dx] += r * h;
          assumedCosts[c.y + dy][c.x + dx] /= mid;
        }
      }

      int rmin = int.max;
      int rmax = int.min;
      foreach(x; 0..N) foreach(y; 0..N) {
        rmax = max(rmax, assumedCosts[y][x]);
        rmin = min(rmin, assumedCosts[y][x]);
      }

      [rmax, rmin].deb;

      foreach(i; 0..N * N) {
        assumedCosts[i / N][i % N] -= rmin;
        assumedCosts[i / N][i % N] *= 5000;
        assumedCosts[i / N][i % N] /= rmax;
        assumedCosts[i / N][i % N].chmax(10);
        currentCosts[i / N][i % N] = assumedCosts[i / N][i % N];
      }

      // assumedCosts.deb;

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

    int excavate(Coord p, bool isTest = false) {
      const x = p.x;
      const y = p.y;
      if (excavated[y][x]) return 0;

      if (isTest) {
        if (tested[y][x]) return -1;
        tested[y][x] = true;
      } else {
        assumedCosts[y][x] = 0;
        currentCosts[y][x] = 0;
        excavated[y][x] = true;
        if (tested[y][x]) return 0;
      }

      int aroundCount;
      int aroundSum;
      foreach(dir, dx, dy; DIRS) {
        auto px = x + dx;
        auto py = y + dy;
        if (min(px, py) < 0 || max(px, py) >= N) continue;
        if (actualCosts[py][px] == 0) continue;

        aroundCount++;
        aroundSum += actualCosts[py][px];
      }

      int sum;
      int incr = max(10, C, aroundCount >= 2 ? (aroundSum / aroundCount).to!int : 0);

      // foreach (power; POWERS) {
      for (int power = incr; sum < COST_MAX; power += incr) {
        debug {} else {
          writefln("%s %s %s", y, x, min(COST_MAX - sum, power));
          stdout.flush;
        }
        sum += power;
        actualCosts[y][x] += power;

        const r = scan!int;
        if (r == 2) finished = true;
        if (r >= 1) return sum;
        if (r != 0) assert(false, "bad request");
        if (sum > 500 && isTest) {
          tested[y][x] = false;
          actualCosts[y][x] = 5000;
          return 5000;
        }
      }
      return sum;
    }
  }

  auto solve() {
    auto uf = UnionFind(WK);
    int[N][N] wid;
    foreach(ref w; wid) w[] = 255;

    auto state = new State();

    foreach(i, c; G[0..W]) {
      state.excavated[c.y][c.x] = true;
      wid[c.y][c.x] = i.to!int;
    }

    while(true) {
      int bestCost = int.max;
      Coord[] bestRoute;
      int bestFrom;
      
      foreach(from; 0..WK) {
        if (uf.root(from) < W) continue;

        auto fc = G[from];
        auto calc = state.calcCostsFrom(fc);
        auto best = calc.bestTarget(state.excavated);
        if (bestCost.chmin(best.cost)) {
          bestFrom = from;
          bestRoute = calc.route(best);
        }
      }

      if (bestCost == int.max) break;

      auto w = wid[bestRoute[0].y][bestRoute[0].x];
      uf.unite(w, bestFrom);

      foreach(i; iota(0, bestRoute.length, 2).array ~ iota(1, bestRoute.length, 2).array) {
        auto c = bestRoute[i];
        wid[c.y][c.x] = w;
        state.excavate(c);
      }
    }

    foreach(c; G[0..W]) {
      state.excavated[c.y][c.x] = false;
      foreach(_, x, y; DIRS) {
        auto dx = c.x + x;
        auto dy = c.y + y;
        if (min(dx, dy) < 0 || max(dx, dy) >= N) continue;

        if (state.excavated[dy][dx]) state.excavate(c);
        if (state.finished) return;
      }
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

struct UnionFind {
  int[] parent;

  this(int size) {
    parent.length = size;
    foreach(i; 0..size) parent[i] = i;
  }

  int root(int x) {
    if (parent[x] == x) return x;
    return parent[x] = root(parent[x]);
  }

  int unite(int x, int y) {
    int rootX = root(x);
    int rootY = root(y);

    if (rootX == rootY) return rootY;
    if (rootX < rootY) swap(rootX, rootY);
    return parent[rootX] = rootY;
  }

  bool same(int x, int y) {
    int rootX = root(x);
    int rootY = root(y);

    return rootX == rootY;
  }
}
