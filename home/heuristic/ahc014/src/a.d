void main() { runSolver(); }

// ----------------------------------------------

enum MAX_N = 50;
enum DIRS = zip([-1, 0, 1, 0], [0, -1, 0, 1]).array;
alias RBT = RedBlackTree!int;
int N = 0;

struct Coord {
  int x, y, dimension;
  this(int x, int y, int dimension = 0) {
    this.x = x;
    this.y = y;
    this.dimension = dimension;
  }

  int score() {
    auto t = dimension == 0 ? this : rotate();
    const half = N / 2;
    return abs(t.x - half)^^2 + abs(t.y - half)^^2 + 1;
  }

  int d() { 
    if (dimension != 0) assert("dont use `d` for rotated coord");
    return (x + y) % 2;
  }
  Coord rotate() {
    if (dimension == 0) {
      if (d == 1) 
        return Coord((y + x - 1) / 2, (y - x + N + 1) / 2, 2);
      else
        return Coord((y + x) / 2, (y - x + N) / 2, 1);
    }
    
    const half = N / 2;
    return Coord(x - y + half + dimension - 1, x + y - half);
  }
}

struct Square {
  Coord[] coords;

  this(Coord[] c) { coords = c; }
  this(Coord a, Coord b) {
    if (a.dimension != 0) {
      const d = a.dimension;
      coords = [a.rotate, Coord(a.x, b.y, d).rotate, b.rotate, Coord(b.x, a.y, d).rotate];
    } else {
      coords = [a, Coord(a.x, b.y), b, Coord(b.x, a.y)];
    }
  }

  bool empty() { return coords.empty; }
  int minX() { return coords.map!"a.x".minElement; }
  int minY() { return coords.map!"a.y".minElement; }
  int maxX() { return coords.map!"a.x".maxElement; }
  int maxY() { return coords.map!"a.y".maxElement; }
  int size() { return empty ? int.max : (maxX - minX + maxY - minY) / (dimension == 0 ? 1 : 2); }
  real score() {
    if (empty) return -1;

    // return coords[0].score() - size()*0;
    return coords[0].score() - size()*100;
  }
  int dimension() {
    if (coords[0].x == coords[1].x) return 0;
    return coords[0].d + 1;
  }
  string toString() {
    return coords.map!(c => [c.x, c.y]).joiner.toAnswerString;
  }
}

struct State {
  RBT[] ax, ay, ux, uy;

  this(Coord[] coords, int size, int type) {
    ax = size.iota.map!(_ => redBlackTree!int([])).array;
    ay = size.iota.map!(_ => redBlackTree!int([])).array;
    ux = size.iota.map!(_ => redBlackTree!int([-1, size])).array;
    uy = size.iota.map!(_ => redBlackTree!int([-1, size])).array;

    if (type == 0) {
      foreach(c; coords) {
        ax[c.y].insert(c.x);
        ay[c.x].insert(c.y);
      }
    } else {
      foreach(cc; coords) {
        if (cc.d + 1 == type) {
          auto c = cc.rotate;
          ax[c.y].insert(c.x);
          ay[c.x].insert(c.y);
        }
      }
    }

    const h = size / 2;
    if (type == 1) {
      foreach(t; 0..h + 1) {
        ux[h + t].insert(-1 + t);
        ux[h + t].insert(size - t);
        ux[h - t].insert(-1 + t);
        ux[h - t].insert(size - t);
        uy[h + t].insert(-1 + t);
        uy[h + t].insert(size - t);
        uy[h - t].insert(-1 + t);
        uy[h - t].insert(size - t);
      }
    } else if (type == 2) {
      foreach(t; 0..h) {
        ux[h + t + 1].insert(-1 + t);
        ux[h + t + 1].insert(size - 1 - t);
        ux[h - t].insert(-1 + t);
        ux[h - t].insert(size - 1 - t);
        uy[h + t].insert(t);
        uy[h + t].insert(size - t);
        uy[h - t - 1].insert(t);
        uy[h - t - 1].insert(size - t);
      }
    }
  }
}

struct Game {
  State[] states;

  this(Coord[] coords) {
    states ~= State(coords, N, 0);
    states ~= State(coords, N, 1);
    states ~= State(coords, N, 2);
  }

  void addSquare(Square sq) {
    if (sq.empty) return;

    foreach(dimension, ref s; states) {
      if (dimension != 0 && sq.coords[0].d != dimension - 1) continue;

      auto toAdd = dimension == 0 ? sq.coords[0] : sq.coords[0].rotate;
      if (toAdd.x in s.ax[toAdd.y] || toAdd.y in s.ay[toAdd.x]) assert("already added");

      s.ax[toAdd.y].insert(toAdd.x);
      s.ay[toAdd.x].insert(toAdd.y);
    }

    with(states[sq.dimension]) {
      auto cds = sq.dimension == 0 ? sq.coords : sq.coords.map!"a.rotate".array;
      foreach(x; min(cds[0].x, cds[2].x)..max(cds[0].x, cds[2].x)) {
        ux[cds[0].y].insert(x);
        ux[cds[2].y].insert(x);
      }
      foreach(y; min(cds[0].y, cds[2].y)..max(cds[0].y, cds[2].y)) {
        uy[cds[0].x].insert(y);
        uy[cds[2].x].insert(y);
      }
    }
  }

  Square[] searchFrom(Coord fromCoord, int[] dimensions = [3, 1, 1]) {
    Square[] ret;
    foreach(dimension, state; states) {
      if (!dimensions[dimension]) continue;
      if (dimension != 0 && fromCoord.d != dimension - 1) continue;
      if (dimension == 0 && (2^^fromCoord.d & dimensions[0]) == 0) continue;

      auto from = dimension == 0 ? fromCoord : fromCoord.rotate;
      with(state) {
        int[] lefts, rights, ups, downs;
        {
          auto leftLimit = ux[from.y].lowerBound(from.x).back;
          foreach_reverse(t; ax[from.y].lowerBound(from.x)) {
            if (leftLimit >= t) break;
            lefts ~= t; break;
          }
          auto rightLimit = ux[from.y].upperBound(from.x - 1).front;
          foreach(t; ax[from.y].upperBound(from.x)) {
            if (rightLimit < t) break;
            rights ~= t; break;
          }

          auto downLimit = uy[from.x].lowerBound(from.y).back;
          foreach_reverse(t; ay[from.x].lowerBound(from.y)) {
            if (downLimit >= t) break;
            downs ~= t; break;
          }

          auto upLimit = uy[from.x].upperBound(from.y - 1).front;
          foreach(t; ay[from.x].upperBound(from.y)) {
            if (upLimit < t) break;
            ups ~= t; break;
          }
        }

        // [lefts, rights, downs, ups].deb;
        foreach(x; lefts ~ rights) {
          foreach(y; downs ~ ups) {
            if (x in ax[y]) continue;
            
            auto l = min(x, from.x);
            auto r = max(x, from.x);
            auto b = min(y, from.y);
            auto t = max(y, from.y);
            if (ux[b].upperBound(l - 1).front < r) continue;
            if (ux[t].upperBound(l - 1).front < r) continue;
            if (uy[l].upperBound(b - 1).front < t) continue;
            if (uy[r].upperBound(b - 1).front < t) continue;
            if (!ax[b].upperBound(l).empty && ax[b].upperBound(l).front < r) continue;
            if (!ax[t].upperBound(l).empty && ax[t].upperBound(l).front < r) continue;
            if (!ay[l].upperBound(b).empty && ay[l].upperBound(b).front < t) continue;
            if (!ay[r].upperBound(b).empty && ay[r].upperBound(b).front < t) continue;

            ret ~= Square(Coord(x, y, dimension.to!int), from);
          }
        }
      }
    }

    return ret;
  }
}

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto rnd = Xorshift(unpredictableSeed);

  N = scan!int;
  const M = scan!int;
  auto P = M.iota.map!(_ => Coord(scan!int, scan!int)).array;

  long calcScore(Coord[] coords) {
    real score = 0;
    const c = N / 2;
    foreach(p; coords) {
      score += (p.x - c)^^2 + (p.y - c)^^2 + 1;
    }
    score *= 10^^6;
    long total;
    foreach(x; 0..N) foreach(y; 0..N) total += (x - c)^^2 + (y - c)^^2 + 1;
    score *= N;
    score *= N;
    score /= total * M;
    return score.to!long;
  }

  auto solve() {
    Square[] ans;
    long score;

    {
      Square[] tAns;
      auto game = Game(P);
      auto coords = P.dup;
      while(true) {
        if (elapsed(4500)) break;

        Square square;
        foreach(dimensions; [[0, 1, 1], [1, 0, 0], [2, 0, 0]]) {
          foreach(coord; coords) {
            auto candidates = game.searchFrom(coord, dimensions);
            if (candidates.empty) continue;

            foreach(candidate; candidates) {
              if (square.empty || square.score < candidate.score) square = candidate;
            }
          }
        }

        if (square.empty) break;

        game.addSquare(square);
        tAns ~= square;
        coords ~= square.coords[0];
      }

      if (score.chmax(calcScore(coords))) ans = tAns;
    }


    stderr.writeln(score);
    ans.length.writeln;
    return ans;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
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
  static import std.datetime.stopwatch;
  enum BORDER = "#==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
