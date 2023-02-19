void main() { runSolver(); }

// ----------------------------------------------

void problem() {
  enum INF = int.max / 3;
  enum COST_MIN = 10;
  enum COST_MAX = 5000;
  enum POWER_MAX = 5000;
  enum N = 200;

  scan!int; // N = 200
  auto W = scan!int;
  auto K = scan!int;
  auto C = scan!int;
  const WK = W + K;
  auto G = scan!int(2 * WK).chunks(2).array;

  enum DIRS = zip([0, 1, 2, 3], [-1, 0, 1, 0], [0, -1, 0, 1]);
  enum DIRSARR = zip([0, 1, 2, 3], [-1, 0, 1, 0], [0, -1, 0, 1]).array;

  class State {
    bool[N][N] excavated;
    bool finished;
    int totalCost;

    int[N][N] assumedCosts;
    int[N][N][16] calcedCosts;
    int[N][N][16] calcedCostFrom;

    this() {
      foreach(i; 0..N * N) {
        assumedCosts[i / N][i % N] = uniform(COST_MIN * 6, COST_MAX / 3 + 1);
      }

      foreach(i; 0..G.length) {
        auto c = calcCostsFrom(i.to!int);
        calcedCosts[i] = c[0];
        calcedCostFrom[i] = c[1];
      }
    }

    Tuple!(int[N][N], int[N][N]) calcCostsFrom(int from) {
      const fromX = G[from][1];
      const fromY = G[from][0];

      int[N][N] costs;
      int[N][N] froms;
      foreach(ref c; costs) c[] = INF;
      foreach(ref c; froms) c[] = -1;
      costs[fromY][fromX] = 0;

      alias Calc = Tuple!(int, "x", int, "y", int, "cost");
      for (auto queue = [Calc(fromX, fromY, 0)].heapify!"a.cost > b.cost"; !queue.empty;) {
        auto p = queue.front; queue.removeFront;
        if (costs[p.y][p.x] != p.cost) continue;

        static foreach(dir, dx, dy; DIRS) {{
          const x = p.x + dx;
          const y = p.y + dy;
          if (min(x, y) >= 0 && max(x, y) < N) {
            if (costs[y][x].chmin(p.cost + assumedCosts[y][x])) {
              froms[y][x] = dir;
              queue.insert(Calc(x, y, costs[y][x]));
            }
          }
        }}
      }

      return tuple(costs, froms);
    }

    int[][] route(int from, int to) {
      int[][] ret;

      int y = G[to][0];
      int x = G[to][1];
      while (calcedCostFrom[from][y][x] != -1) {
        ret ~= [x, y];
        const d = calcedCostFrom[from][y][x];
        x -= DIRSARR[d][1];
        y -= DIRSARR[d][2];
      }

      ret ~= [x, y];
      return ret;
    }

    int excavate(int x, int y) {
      if (excavated[y][x]) return 0;
      excavated[y][x] = true;

      int limit = POWER_MAX;
      int sum;
      for(int e = 4;; e *= 1.5) {
        int power = min(limit - sum, 7 + e);
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
      costs[2 ^^ st][st] = state.assumedCosts[G[st][0]][G[st][1]];
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
          const cost = costs[fromState][from] + state.calcedCosts[from][G[to][0]][G[to][1]];
          costs[toState][to].chmin(cost);
          routes[toState][to] = routes[fromState][from] ~ to;

          if (toState > satisfy && bestCost.chmin(cost)) {
            bestRoute = routes[toState][to];
          }
        }
      }
    }

    // state.route(0, 1).deb;
    
    int from = bestRoute[0];
    foreach(to; bestRoute[1..$]) {
      foreach(p; state.route(from, to)) {
        state.excavate(p[0], p[1]);
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
