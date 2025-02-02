void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  string[] G = scan!string(N);

  enum MOVE = "ULDR";
  struct Move {
    int dir, index;

    string asAns() {
      return "%s %s".format(MOVE[dir..dir + 1], index);
    }
  }

  long oTotal = G.map!"a.count('o')".sum;
  long xTotal = G.map!"a.count('x')".sum;

  struct State {
    int turn;
    int[][] grid;

    this(int turn, int[][] grid) {
      this.turn = turn;
      this.grid = grid;
    }

    long restX() {
      return grid.map!"a.count(1)".sum;
    }

    long score() {
      long penalty = (oTotal - grid.map!"a.count(2)".sum) * 1_000_000_000;
      long score = (xTotal - grid.map!"a.count(1)".sum) * 1_000_000;

      foreach(r; 0..N) foreach(c; 0..N) {
        if (grid[r][c] != 1) continue;
        
        score += 100_000 / min(r + 1, c + 1, N - r, N - c);
      }
      
      foreach(r; 0..N) foreach(sc; [0, N / 2]) {
        long cont, contMax;
        foreach(t; 0..N / 2) {
          if (grid[r][sc + t] == 1) cont++;
          if (grid[r][sc + t] == 2) cont = 0;
          contMax = max(contMax, cont);
        }

        score += 10_000 * contMax;
      }
      
      foreach(c; 0..N) foreach(sr; [0, N / 2]) {
        long cont, contMax;
        foreach(t; 0..N / 2) {
          if (grid[sr + t][c] == 1) cont++;
          if (grid[sr + t][c] == 2) cont = 0;
          contMax = max(contMax, cont);
        }

        score += 10_000 * contMax;
      }

      foreach(r; 0..N) foreach(c; 0..N) {
        if (grid[r][c] != 2) continue;
        
        if (r < N / 2) {
          foreach(t; 1..10) {
            if (r + t > N / 2) break;
            if (grid[r + t][c] == 1) penalty += 1_000 / t;
          }
        } else {
          foreach(t; 1..10) {
            if (r - t <= N / 2) break;
            if (grid[r - t][c] == 1) penalty += 1_000 / t;
          }
        }
        
        if (c < N / 2) {
          foreach(t; 1..10) {
            if (c + t > N / 2) break;
            if (grid[r][c + t] == 1) penalty += 1_000 / t;
          }
        } else {
          foreach(t; 1..10) {
            if (c - t <= N / 2) break;
            if (grid[r][c - t] == 1) penalty += 1_000 / t;
          }
        }
      }

      return score - penalty;
    }

    State move(Move move) {
      auto moved = grid.map!"a.dup".array;
      auto index = move.index;

      if (move.dir % 2 == 1) {
        if (move.dir == 1) {
          moved[index] = moved[index][1..$] ~ 0;
        } else {
          moved[index] = 0 ~ moved[index][0..$ - 1];
        }
      } else {
        if (move.dir == 0) {
          foreach(r; 0..N - 1) moved[r][index] = moved[r + 1][index];
          moved[N - 1][index] = 0;
        } else {
          foreach_reverse(r; 1..N) moved[r][index] = moved[r - 1][index];
          moved[0][index] = 0;
        }
      }

      return State(turn + 1, moved);
    }
  }

  State initState = {
    int[][] grid = new int[][](N, N);
    foreach(r; 0..N) foreach(c; 0..N) grid[r][c] = G[r][c] == '.' ? 0 : G[r][c] == 'x' ? 1 : 2;
    grid.each!deb;
    return State(0, grid);
  }();

  initState.score.deb;
  auto cur = initState;
  int limit = 4 * N^^2;
  while(cur.turn < limit && cur.restX > 0) {
    Move bestMove;
    State bestState;
    long bestScore = long.min;
    int bestStep;

    foreach(i; 0..N) foreach(dir; 0..4) foreach(step; 1..5) {
      auto next = cur.move(Move(dir, i));
      foreach(_; 1..step) next = next.move(Move(dir, i));

      if (bestScore.chmax(next.score)) {
        bestMove = Move(dir, i);
        bestState = next;
        bestStep = step;
      }
    }

    foreach(_; 0..bestStep) writeln(bestMove.asAns());
    bestScore.deb;
    cur = bestState;
  }
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
