void main() { runSolver(); }

// ----------------------------------------------

enum GRID_SIZE = 20;
enum WALKS_LIMIT = 200;

struct Point {
  int y, x;
  Point add(Point other) { return Point(y + other.y, x + other.x); }
  Point sub(Point other) { return Point(y - other.y, x - other.x); }
  int distance(Point other) { return (other.x - x).abs + (other.y - y).abs; }
  bool isValid() { return min(x, y) >= 0 && max(x, y) < GRID_SIZE; }
}
enum WALKS = [
  'U': Point(-1, 0),
  'D': Point(1, 0),
  'L': Point(0, -1),
  'R': Point(0, 1),
];
enum WALKS_REV = [
  'U': 'D',
  'D': 'U',
  'L': 'R',
  'R': 'L',
];
alias Walk = Tuple!(dchar, "move", int, "cost", Point, "dest", Point, "src");

struct Walks {
  Walk[] values;

  void add(Walk w) { values ~= w; }
  int cost() { return values.map!"a.cost".sum; }
  string asAns() { return values.map!"a.move.repeat(a.cost)".joiner.to!string; }

  void rubosten(real p, real k) {
    auto expects = values.map!"a.cost".array;
    
    foreach(_; 0..(WALKS_LIMIT - 0) - cost) {
      real lowestProb = int.max;
      long lowestIndex;
      foreach(i, w; values) {
        real t = w.cost.to!real * (1.0 - p) - expects[i];
        if (lowestProb.chmin(t)) lowestIndex = i;
      }
      if (lowestProb >= k) break;
      values[lowestIndex].cost++;
    }
  }
}

class Game {
  Point start, goal;
  real p;
  bool[GRID_SIZE][GRID_SIZE] xWalls; 
  bool[GRID_SIZE][GRID_SIZE] yWalls;

  this(Point s, Point g, real pp, string[] wh, string[] wv) {
    start = s;
    goal = g;
    p = pp;

    foreach(y, h; wh) foreach(x, c; h) xWalls[y][x] = c == '0';
    foreach(y, h; wv) foreach(x, c; h) yWalls[y][x] = c == '0';
    gridScore = calcGridScore();
  }

  bool canMove(Point s, Point d) {
    auto t = s.add(d);
    if (!t.isValid) return false;

    if (d.y == 0) {
      const dx = (s.x * 2 + d.x) / 2;
      return xWalls[s.y][dx];
    } else {
      const dy = (s.y * 2 + d.y) / 2;
      return yWalls[dy][s.x];
    }
  }

  int[GRID_SIZE][GRID_SIZE] gridScore;
  dchar[GRID_SIZE][GRID_SIZE] gridWalk;
  int[GRID_SIZE][GRID_SIZE] calcGridScore() {
    int[GRID_SIZE][GRID_SIZE] score;
    foreach(ref s; score) s[] = 9999;

    int step;
    for(auto q = DList!Point([goal]); !q.empty;) {
      bool[Point] next;
      while(!q.empty) {
        auto p = q.front; q.removeFront;
        score[p.y][p.x] = step;
        foreach(m, w; WALKS) {
          if (canMove(p, w)) {
            auto n = p.add(w);
            if (score[n.y][n.x] == 9999) {
              next[n] = true;
              gridWalk[n.y][n.x] = m;
            }
          }
        }
      }
      step++;
      foreach(p; next.keys) q.insertBack(p);
    }
    return score;
  }

  Walk[] walk(Point s) {
    Walk[] ret;
    foreach(m, walk; WALKS) {
      if (!canMove(s, walk)) continue;

      auto t = s;
      int dist;
      while(canMove(t, walk)) {
        t = t.add(walk);
        dist++;
        if (t == goal) break;
      }
      ret ~= Walk(m, dist, t, s);
    }

    // s.deb;
    // ret.each!deb;
    return ret;
  }

  Walks simulate() {
    Walk[GRID_SIZE][GRID_SIZE] grid;
    int[GRID_SIZE][GRID_SIZE] costs;
    foreach(ref c; costs) c[] = int.max;
    costs[start.y][start.x] = 0;

    alias Exam = Tuple!(Point, "p", int, "cost");
    Point nearest = start;
    int nearestScore = int.max;
    int nearness(Point p) {
      return gridScore[p.y][p.x]*5 + costs[p.y][p.x]*2;
    }
    
    for(auto q = [Exam(start, 0)].heapify!"a.cost > b.cost"; !q.empty;) {
      auto e = q.front; q.removeFront;
      if (nearestScore.chmin(nearness(e.p))) {
        nearest = e.p;
      }
      if (e.p == goal) {
        nearest = goal;
        break;
      }
      if (costs[e.p.y][e.p.x] < e.cost) continue;

      foreach(w; walk(e.p)) {
        const c = e.cost + w.cost;

        if (costs[w.dest.y][w.dest.x] > c) {
          costs[w.dest.y][w.dest.x] = c;
          grid[w.dest.y][w.dest.x] = w;
          q.insert(Exam(w.dest, c));
        }
      }
    }

    // costs.each!deb;
    // costs[goal.y][goal.x].deb;

    if (costs[nearest.y][nearest.x] == int.max) {
      return Walks([]);
    }

    Walk[] ret;
    auto t = nearest;
    while(t != start) {
      auto g = grid[t.y][t.x];
      ret ~= g;
      t = g.src;
    }

    auto walks = Walks(ret.reverse.array);
    walks.rubosten(p, nearest == goal ? 2.00 + p*4 : 2.00 + p*4);

    if (goal != nearest) {
      dchar[] bfsWalk;
      t = nearest;
      while(t != goal) {
        bfsWalk ~= WALKS_REV[cast(char)gridWalk[t.y][t.x]];
        t = t.sub(WALKS[cast(char)gridWalk[t.y][t.x]]);
      }

      foreach(i; 0..WALKS_LIMIT - walks.cost) {
        walks.values ~= Walk(bfsWalk[i % bfsWalk.length], 1, goal, goal);
      }
    }

    return walks;
  }
}

void problem() {
  auto S = Point(scan!int, scan!int);
  auto T = Point(scan!int, scan!int);
  auto P = scan!real;
  auto WH = scan!string(GRID_SIZE);
  auto WV = scan!string(GRID_SIZE - 1);

  auto solve() {
    auto game = new Game(S, T, P, WH, WV);

    auto walks = game.simulate();
    return walks.asAns;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
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
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
