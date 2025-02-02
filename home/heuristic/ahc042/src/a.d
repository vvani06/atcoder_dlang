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

  class Coord {
    int r, c;

    this(int r, int c) {
      this.r = r;
      this.c = c;
    }

    int outDistance() {
      return min(
        r + 1,
        c + 1,
        N - r,
        N - c,
      );
    }

    int outDir() {
      return [
        r + 1,
        c + 1,
        N - r,
        N - c,
      ].minIndex.to!int;
    }
  }

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
    int[][] oCol;
    int[][] oRow;
    int[][] xCol;
    int[][] xRow;

    this(int turn, int[][] oc, int[][] or, int[][] xc, int[][] xr) {
      this.turn = turn;
      oCol = oc;
      oRow = or;
      xCol = xc;
      xRow = xr;
    }

    long restX() {
      return xCol.map!"a.length".sum;
    }

    long score() {
      long penalty = (oTotal - oCol.map!"a.length".sum) * 1_000_000_000;
      long score = (xTotal - xCol.map!"a.length".sum) * 500_000;

      foreach(r; 0..N) {
        foreach(i; 0..xRow[r].length.to!int - 1) {
          auto l = xRow[r][i];
          auto u = xRow[r][i + 1];
          score += 10_000 / (u - l);
          penalty += oRow[r].assumeSorted.upperBound(l).lowerBound(u).length * 50;
        }
      }

      foreach(c; 0..N) {
        foreach(i; 0..xCol[c].length.to!int - 1) {
          auto l = xCol[c][i];
          auto u = xCol[c][i + 1];
          score += 10_000 / (u - l);
          penalty += oCol[c].assumeSorted.upperBound(l).lowerBound(u).length * 50;
        }
      }

      return score - penalty;
    }

    State move(Move move) {
      auto movedOCol = oCol.dup;
      auto movedORow = oRow.dup;
      auto movedXCol = xCol.dup;
      auto movedXRow = xRow.dup;

      if (move.dir % 2 == 1) {
        int delta = move.dir == 1 ? -1 : 1;

        movedXRow[move.index][] += delta;
        movedXRow[move.index] = movedXRow[move.index].filter!(t => 0 <= t && t < N).array;
        movedORow[move.index][] += delta;
        movedORow[move.index] = movedORow[move.index].filter!(t => 0 <= t && t < N).array;
        foreach(ref col; [movedXCol, movedOCol]) {
          foreach(i; delta == -1 ? N.iota.array : N.iota.retro.array) {
            if (!col[i].canFind(move.index)) continue;

            col[i] = col[i].filter!(r => r != move.index).array;
            auto t = i + delta;
            if (0 <= t && t < N) col[t] = (col[t] ~ move.index).sort.array;
          }
        }
      } else {
        int delta = move.dir == 0 ? -1 : 1;

        movedXCol[move.index][] += delta;
        movedXCol[move.index] = movedXCol[move.index].filter!(t => 0 <= t && t < N).array;
        movedOCol[move.index][] += delta;
        movedOCol[move.index] = movedOCol[move.index].filter!(t => 0 <= t && t < N).array;
        foreach(ref row; [movedXRow, movedORow]) {
          foreach(i; delta == -1 ? N.iota.array : N.iota.retro.array) {
            if (!row[i].canFind(move.index)) continue;

            row[i] = row[i].filter!(r => r != move.index).array;
            auto t = i + delta;
            if (0 <= t && t < N) row[t] = (row[t] ~ move.index).sort.array;
          }
        }
      }

      return State(turn + 1, movedOCol, movedORow, movedXCol, movedXRow);
    }
  }

  State initState = {
    int[][] oCol = new int[][](N, 0);
    int[][] oRow = new int[][](N, 0);
    int[][] xCol = new int[][](N, 0);
    int[][] xRow = new int[][](N, 0);
    foreach(r; 0..N) foreach(c; 0..N) {
      if (G[r][c] == 'o') {
        oCol[c] ~= r;
        oRow[r] ~= c;
      }
      if (G[r][c] == 'x') {
        xCol[c] ~= r;
        xRow[r] ~= c;
      }
    }

    return State(0, oCol, oRow, xCol, xRow);
  }();

  initState.score.deb;
  auto cur = initState;
  int limit = 4 * N^^2;
  while(cur.turn < limit && cur.restX > 0) {
    Move bestMove;
    State bestState;
    long bestScore = long.min;

    foreach(i; 0..N) foreach(dir; 0..4) {
      auto next = cur.move(Move(dir, i));
      if (bestScore.chmax(next.score)) {
        bestMove = Move(dir, i);
        bestState = next;
      }
    }

    writeln(bestMove.asAns());
    bestScore.deb;
    cur = bestState;
  }

  cur.oRow.each!deb;
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
