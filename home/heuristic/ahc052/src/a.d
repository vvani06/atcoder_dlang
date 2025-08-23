void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int M = scan!int;
  int K = scan!int;
  int[][] RC = scan!int(2 * M).chunks(2).array;
  string[] V = scan!string(N);
  string[] H = scan!string(N - 1);

  enum DIRS = "LURDS";
  enum MOVES_R = [0, -1, 0, 1, 0];
  enum MOVES_C = [-1, 0, 1, 0, 0];

  class Grid {
    bool[][] left;
    bool[][] right;
    bool[][] up;
    bool[][] down;

    this(string[] v, string[] h) {
      left = new bool[][](N, N);
      right = new bool[][](N, N);
      foreach(r; 0..N) foreach(c; 0..N - 1) {
        if (v[r][c] == '0') {
          right[r][c] = true;
          left[r][c + 1] = true;
        }
      }
      up = new bool[][](N, N);
      down = new bool[][](N, N);
      foreach(r; 0..N - 1) foreach(c; 0..N) {
        if (h[r][c] == '0') {
          down[r][c] = true;
          up[r + 1][c] = true;
        }
      }

      left[14].deb;
    }

    bool canWalk(int r, int c, int dir) {
      if (dir == 0) return left[r][c];
      if (dir == 1) return up[r][c];
      if (dir == 2) return right[r][c];
      if (dir == 3) return down[r][c];
      return false;
    }
  }

  class Controller {
    int[][] dirs;

    this(string[] commands) {
      dirs = new int[][](K, M);
      foreach(m; 0..M) foreach(k; 0..K) {
        dirs[k][m] = DIRS.countUntil(commands[m][k]).to!int;
      }
    }

    int dir(int robot, int command) {
      return dirs[command][robot];
    }

    void outputAsAns() {
      foreach(d; dirs) {
        writefln("%s", d.map!(x => DIRS[x..x + 1]).joiner(" "));
      }
    }
  }

  class Simulator {
    Grid grid;
    Controller controller;
    int[] operations;

    bool[][] filled;
    int rest;
    int[] r;
    int[] c;
    
    int valuesless;
    int[] vr;
    int[] vc;

    this(Grid grid, Controller contoller, int[][] RC) {
      this.grid = grid;
      this.controller = contoller;
      r = RC.map!"a[0]".array;
      c = RC.map!"a[1]".array;
      filled = new bool[][](N, N);
      foreach(rr, cc; zip(r, c)) {
        filled[rr][cc] = true;
      }
      rest = N^^2 - M;
    }

    void add(int command) {
      if (rest <= 0) return;

      int moved;
      int fill;
      foreach(m; 0..M) {
        auto dir = controller.dir(m, command);
        if (grid.canWalk(r[m], c[m], dir)) {
          moved++;
          r[m] += MOVES_R[dir];
          c[m] += MOVES_C[dir];
          if (!filled[r[m]][c[m]]) {
            filled[r[m]][c[m]] = true;
            rest--;
            fill++;
          }
        }
      }

      if (moved > 0) {
        operations ~= command;

        if (fill > 0) {
          if (rest <= 50) {
            valuesless = 0;
            vr = r.dup;
            vc = c.dup;
          }
        } else {
          valuesless++;
        }
      }
    }

    void add(int[] commands) {
      foreach(c; commands) add(c);
    }

    int score() {
      if (rest > 0) return N ^^ 2 - rest;
      return 3 * N^^2 - operations.length.to!int;
    }

    void cutEdge() {
      if (valuesless == 0 || vr.empty) return;

      r = vr.dup;
      c = vc.dup;
      operations = operations[0..$ - valuesless];
      valuesless = 0;
    }

    void outputAsAns() {
      controller.outputAsAns();
      writefln("%(%s %)", operations[0..min($, 2*N^^2)]);
    }
  }

  Grid grid = new Grid(V, H);
  Simulator bestSim;
  int bestScore;
  while(!elapsed(1900)) {
    auto commands = M.iota.map!(_ => "LURDLURDLURDLURD"[uniform(0, 4, RND)..$]).array;
    // auto commands = M.iota.map!(_ => "DRULDRULDRULDRUL"[uniform(0, 4, RND)..$]).array;
    Controller controller = new Controller(commands);
    Simulator sim = new Simulator(grid, controller, RC);
    auto mode1 = uniform(0, 2, RND);
    auto mode2 = uniform(0, 2, RND);
    auto stepWidth = [30, 28, 26, 24, 22, 20, 18, 16, 14, 12, 10].choice(RND);
    auto initStepWidth = [30, 25, 20, 15, 10].choice(RND);

    int[] aligns = [
      [0, 2].choice(RND),
      [1, 3].choice(RND),
    ];

    foreach(al; mode2 == 0 ? aligns : aligns.retro.array) {
      sim.add(repeat(al, initStepWidth).array);
    }

    int forward = 4.iota.filter!(n => !aligns.canFind(n)).array.choice(RND);
    int sideFirst = (forward + 1) % 4;
    int sideSecond = (sideFirst + 2) % 4;

    foreach(c; 0..N) {
      if (mode1 == 0) sim.add(forward);
      sim.add(repeat(sideFirst, stepWidth).array);
      sim.add(forward);
      sim.add(repeat(sideSecond, stepWidth).array);
      if (mode1 == 1) sim.add(forward);
    }

    if (sim.rest > 0) {
      sim.cutEdge();
      foreach(c; sim.operations.retro) {
        sim.add(c + 2);
      }
    }

    if (bestScore.chmax(sim.score)) bestSim = sim;
  }

  bestSim.deb;
  bestSim.outputAsAns();
}

// ----------------------------------------------

import std;
import core.bitop;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(lazy T t){ debug { write("# "); writeln(t); }}
void debf(T ...)(lazy T t){ debug { write("# "); writefln(t); }}
// void deb(T ...)(T t){ debug {  }}
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
