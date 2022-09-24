void main() { runSolver(); }

// ----------------------------------------------

enum MAX_N = 50;
enum DIRS = zip([-1, 0, 1, 0], [0, -1, 0, 1]).array;
alias RBT = RedBlackTree!int;
int N = 0;

struct Coord {
  int x, y;
  int d() { return (x + y) % 2; }
  Coord rotate() {
    if (d == 1) return Coord((y + x - 1) / 2, (y - x + N + 1) / 2);
    return Coord((y + x) / 2, (y - x + N) / 2);
  }
}

struct State {
  RBT[] ax, ay, ux, uy;

  this(Coord[] coords, int size, int type) {
    ax = size.iota.map!(_ => redBlackTree!int([])).array;
    ay = size.iota.map!(_ => redBlackTree!int([])).array;
    ux = size.iota.map!(_ => redBlackTree!int([-1, size])).array;
    uy = size.iota.map!(_ => redBlackTree!int([-1, size])).array;
    
    foreach(c; coords) {
      ax[c.y].insert(c.x);
      ay[c.x].insert(c.y);
    }
  }

  void addSquare(Square sq) {
    if (sq.empty) return;

    const toAdd = sq.coords[0];
    if (toAdd.x in ax[toAdd.y] || toAdd.y in ay[toAdd.x]) assert("already added");

    ax[toAdd.y].insert(toAdd.x);
    ay[toAdd.x].insert(toAdd.y);

    foreach(x; min(sq.coords[0].x, sq.coords[2].x)..max(sq.coords[0].x, sq.coords[2].x)) {
      ux[sq.coords[0].y].insert(x);
      ux[sq.coords[2].y].insert(x);
    }
    foreach(y; min(sq.coords[0].y, sq.coords[2].y)..max(sq.coords[0].y, sq.coords[2].y)) {
      uy[sq.coords[0].x].insert(y);
      uy[sq.coords[2].x].insert(y);
    }
  }

  Square searchFrom(Coord from) {
    int[] lefts, rights, ups, downs;
    {
      auto leftLimit = ux[from.y].lowerBound(from.x).back;
      foreach_reverse(t; ax[from.y].lowerBound(from.x)) {
        if (leftLimit >= t) break;
        lefts ~= t; break;
      }
      auto rightLimit = ux[from.y].upperBound(from.x - 1).front;
      foreach(t; ax[from.y].upperBound(from.x)) {
        if (rightLimit <= t) break;
        rights ~= t; break;
      }

      auto downLimit = uy[from.x].lowerBound(from.y).back;
      foreach_reverse(t; ay[from.x].lowerBound(from.y)) {
        if (downLimit >= t) break;
        downs ~= t; break;
      }

      auto upLimit = uy[from.x].upperBound(from.y - 1).front;
      foreach(t; ay[from.x].upperBound(from.y)) {
        if (upLimit <= t) break;
        ups ~= t; break;
      }
    }
    
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
        if (ax[b].upperBound(l).front < r) continue;
        if (ax[t].upperBound(l).front < r) continue;
        if (ay[l].upperBound(b).front < t) continue;
        if (ay[r].upperBound(b).front < t) continue;

        return Square(Coord(x, y), from);
      }
    }

    return Square([]);
  }
}

struct Square {
  Coord[] coords;

  this(Coord[] c) { coords = c; }
  this(Coord a, Coord b) {
    coords = [a, Coord(a.x, b.y), b, Coord(b.x, a.y)];
  }

  bool empty() { return coords.empty; }
  int minX() { return min(coords[0].x, coords[2].x); }
  int minY() { return min(coords[0].y, coords[2].y); }
  int maxX() { return max(coords[0].x, coords[2].x); }
  int maxY() { return max(coords[0].y, coords[2].y); }
  int size() { return empty ? int.max : maxX - minX + maxY - minY; }
  string toString() {
    return coords.map!(c => [c.x, c.y]).joiner.toAnswerString;
  }
}

void problem() {
  N = scan!int;
  const M = scan!int;
  auto P = M.iota.map!(_ => Coord(scan!int, scan!int)).array;

  auto solve() {
    auto state = State(P, N, 0);
    Square[] ans;

    MAIN: while(true) {
      Square square;
      foreach(coord; P) {
        auto candidate = state.searchFrom(coord);
        if (square.size > candidate.size) square = candidate;
      }

      if (square.empty) break;
      state.addSquare(square);
      ans ~= square;
      P ~= square.coords[0];
    }

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
