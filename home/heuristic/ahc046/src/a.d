void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  enum MOVE = 0;
  enum SKATE = 1;
  enum MOD = 2;

  enum U = 0;
  enum D = 1;
  enum L = 2;
  enum R = 3;

  enum DR = [-1, 1, 0, 0];
  enum DC = [0, 0, -1, 1];

  struct Coord {
    int r, c;
    int cost;
  }

  struct Action {
    int type = -1, dir;
    Coord from;

    string asOutput() {
      enum TYPES = "MSA";
      enum DIRS = "UDLR";
      return "%s %s".format(TYPES[type], DIRS[dir]);
    }
  }

  int N = scan!int;
  int M = scan!int;
  Coord[] goals = scan!int(2 * M).chunks(2).map!(c => Coord(c[0], c[1])).array;

  Action[] search(Coord from, Coord to, bool[][] blocked) {
    int[][] costs = new int[][](N, N);
    Action[][] actions = new Action[][](N, N);
    foreach(ref c; costs) c[] = int.max;
    costs[from.r][from.c] = 0;

    bool walkable(int r, int c) {
      if (min(r, c) < 0 || max(r, c) >= N) return false;
      return !blocked[r][c];
    }

    for(auto queue = [from].heapify!"a.cost > b.cost"; !queue.empty;) {
      auto cur = queue.front;
      queue.removeFront;
      if (cur.r == to.r && cur.c == to.c) break;
      if (cur.cost != costs[cur.r][cur.c]) continue;

      int nextCost = cur.cost + 1;
      foreach(dir; 0..4) {
        foreach(step; 1..N + 1) {
          int r = cur.r + DR[dir]*step;
          int c = cur.c + DC[dir]*step;

          if (step == 1) {
            if (!walkable(r, c)) break;

            if (costs[r][c].chmin(nextCost)) {
              costs[r][c] = nextCost;
              actions[r][c] = Action(MOVE, dir, cur);
              queue.insert(Coord(r, c, nextCost));
            }
          } else if (!walkable(r, c)) {
            r -= DR[dir];
            c -= DC[dir];

            if (costs[r][c].chmin(nextCost)) {
              costs[r][c] = nextCost;
              actions[r][c] = Action(SKATE, dir, cur);
              queue.insert(Coord(r, c, nextCost));
            }
            break;
          }
        }
      }
    }

    if (actions[to.r][to.c].type == -1) {
      return actions[to.r][to.c].repeat(50).array;
    }

    Action[] ret;
    for(Coord c = to; c != from; c = actions[c.r][c.c].from) {
      ret ~= actions[c.r][c.c];
    }
    ret.reverse();
    return ret;
  }

  Action[] estimate(int start, bool[][] state) {
    Action[] ret;
    foreach(i; start..M) {
      Coord cur = goals[i - 1];
      Coord goal = goals[i];
      
      ret ~= search(cur, goal, state);
    }
    return ret;
  }


  bool[][] state = new bool[][](N, N);
  string[] ans;

  Action[] toggleAround(Coord cur, int sw) {
    Action[] ret;
    foreach(dir; 0..4) {
      if ((sw & (2^^dir)) == 0) continue;
      
      auto r = cur.r + DR[dir];
      auto c = cur.c + DC[dir];
      if (min(r, c) < 0 || max(r, c) >= N) continue;

      state[r][c] ^= 1;
      ret ~= Action(MOD, dir);
    }
    return ret;
  }

  foreach(i; 1..M) {
    Coord cur = goals[i - 1];
    Coord goal = goals[i];

    int bestToggle;
    int best = int.max;
    foreach(toggle; 0..2^^4) {
      toggleAround(cur, toggle);
      if (best.chmin(popcnt(toggle) + estimate(i, state).length.to!int)) {
        bestToggle = toggle;
      }
      toggleAround(cur, toggle);
    }
    
    Action[] actions = toggleAround(cur, bestToggle);
    actions ~= search(cur, goal, state);
    foreach(act; actions) {
      ans ~= act.asOutput();
    }
  }

  foreach(a; ans) writeln(a);
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
