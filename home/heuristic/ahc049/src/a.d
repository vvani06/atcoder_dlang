void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int[][] W = scan!int(N * N).chunks(N).array;
  int[][] D = scan!int(N * N).chunks(N).array;

  struct Coord {
    int r, c;

    T of(T)(T[][] matrix) {
      return matrix[r][c];
    }

    inout int opCmp(inout Coord other) {
      return cmp(
        [r, c],
        [other.r, other.c],
      );
    }
  }

  class Item {
    int id, w, d;

    this(int id, int w, int d) {
      this.id = id;
      this.w = w;
      this.d = d;
    }

    int score() {
      return w + d * 4;
    }
  }

  class Operation {
    Coord[] picks;
    int[][] damages;
    string actions;
    int cost;

    this(Coord[] p) {
      picks = p.dup;
      damages = new int[][](picks.length, 0);

      Coord cur;
      foreach(i, next; picks ~ Coord(0, 0)) {
        cost += abs(cur.r - next.r) + abs(cur.c - next.c);
        foreach(base; 0..i) {
          damages[base] ~= abs(cur.r - next.r) + abs(cur.c - next.c);
        }
        while(cur.r > next.r) {
          cur.r--;
          actions ~= 'U';
        }
        while(cur.r < next.r) {
          cur.r++;
          actions ~= 'D';
        }
        while(cur.c > next.c) {
          cur.c--;
          actions ~= 'L';
        }
        while(cur.c < next.c) {
          cur.c++;
          actions ~= 'R';
        }
        if (next != Coord(0, 0)) actions ~= '1';
      }
    }

    string asAns() {
      return actions.map!(c => [c, ' ']).joiner.to!string;
    }
  }

  class State {
    Item[] items;
    int[][] grid;

    this() {
      grid = (N^^2).iota.array.chunks(N).array;
      items = (N^^2).iota.map!(i => new Item(i, W[i / N][i % N], D[i / N][i % N])).array;
    }

    Item[] itemsFromCoord(Coord[] coords) {
      return coords.map!(c => c.of(grid)).filter!(i => i != 0).map!(i => items[i]).array;
    }

    Item item(int r, int c) {
      return items[grid[r][c]];
    }
    Item item(Coord c) {
      return item(c.r, c.c);
    }

    int[] calc(Operation op) {
      auto picked = itemsFromCoord(op.picks);
      auto w = picked.map!"a.w".array;
      auto ret = picked.map!"a.d".array;

      foreach(t, damage; op.damages) {
        int dd;
        // damage[1 .. $].deb;
        // w[t + 1..$].deb;
        foreach(step, d; zip(damage[1 .. $], w[t + 1..$])) {
          dd += d;
          ret[t] -= step * dd;
        }
      }

      return ret;
    }
  }

  State state = new State();
  string[] ans;
  enum UNIT_ROW = 5;

  auto candidatesRow = new Coord[](0).redBlackTree;
  foreach(r; 0..UNIT_ROW) candidatesRow.insert(N.iota.map!(c => Coord(r, c)));
  candidatesRow.removeKey(Coord(0, 0));

  auto candidatesCol = new Coord[](0).redBlackTree;
  foreach(c; 0..UNIT_ROW) candidatesCol.insert(N.iota.map!(r => Coord(r, c)));
  candidatesCol.removeKey(Coord(0, 0));

  auto restRows = UNIT_ROW.iota.redBlackTree;
  auto restCols = UNIT_ROW.iota.redBlackTree;
  int nextRow = UNIT_ROW;
  int nextCol = UNIT_ROW;

  while(!candidatesRow.empty) {
    foreach(rowcol; 0..2) {
      auto candidates = rowcol == 0 ? &candidatesRow : &candidatesCol;
      auto carr = candidates.array;
      if (carr.empty) break;
      Coord[] coords = [carr[0]];

      if (carr.length > 1) {
        int maxMin;
        int[] bestPair;
        foreach(i; 0..carr.length.to!int - 1) foreach(j; i + 1..carr.length.to!int) {
          auto t1 = [carr[i], carr[j]];
          auto op1 = new Operation(t1);
          auto min1 = state.calc(op1).minElement;

          auto t2 = [carr[j], carr[i]];
          auto op2 = new Operation(t2);
          auto min2 = state.calc(op2).minElement;

          if (maxMin.chmax(min1)) bestPair = [i, j];
          if (maxMin.chmax(min2)) bestPair = [j, i];
        }

        if (!bestPair.empty) {
          candidates.removeKey(carr[bestPair[0]], carr[bestPair[1]]);
          coords = [carr[bestPair[0]], carr[bestPair[1]]];

          while(true) {
            maxMin = 0;
            Coord bestCoord;
            foreach(coord; candidates.array) {
              auto op = new Operation(coords ~ coord);
              auto calced = state.calc(op);

              if (maxMin.chmax(calced.minElement)) {
                bestCoord = coord;
              }
            }
            
            if (maxMin == 0) break;
            coords ~= bestCoord;
            candidates.removeKey(bestCoord);
          }
        }
      }

      Operation bestOp = new Operation(coords);
      foreach(_; 0..100) {
        auto op = new Operation(coords.randomShuffle(RND));
        if (state.calc(op).minElement > 0 && bestOp.cost > op.cost) bestOp = op;
      }

      ans ~= bestOp.asAns;
      foreach(c; coords) {
        candidatesRow.removeKey(c);
        candidatesCol.removeKey(c);
        state.grid[c.r][c.c] = 0;
      }

      foreach(r; restRows.array) {
        if (state.grid[r].all!(i => i == 0)) {
          restRows.removeKey(r);
          if (nextRow < N) {
            restRows.insert(nextRow);
            foreach(c; 0..N) {
              if (state.grid[nextRow][c] != 0) candidatesRow.insert(Coord(nextRow, c));
            }
            nextRow++;
          }
        }
      }
      foreach(c; restCols.array) {
        if (N.iota.all!(r => state.grid[r][c] == 0)) {
          restCols.removeKey(c);
          if (nextCol < N) {
            restCols.insert(nextCol);
            foreach(r; 0..N) {
              if (state.grid[r][nextCol] != 0) candidatesCol.insert(Coord(r, nextCol));
            }
            nextCol++;
          }
        }
      }
    }
  }

  foreach(c; ans) writeln(c);
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
