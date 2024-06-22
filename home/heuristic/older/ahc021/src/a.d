void main() { runSolver(); }

// ----------------------------------------------

enum N = 30;

struct Swap {
  int fx, fy, tx, ty;

  this(Coord from, Coord to) {
    fx = from.x;
    fy = from.y;
    tx = to.x;
    ty = to.y;
  }

  void exec(ref int[][] balls) {
    if (min(fx, fy, tx, ty) < 0 || max(fx, fy, tx, ty) >= N || abs(fx - tx) > 1 || abs(fy - ty) > 1) {
      [fx, fy, tx, ty].deb;
      throw new Exception("invalid swap");
    }

    if (balls[fx][fy] == -1 || balls[tx][ty] == -1) {
      throw new Exception("invalid coord");
    }

    swap(balls[fx][fy], balls[tx][ty]);
  }
}

struct Coord {
  int x, y;

  Coord[] around() {
    Coord[] ret;
    if (x > 0) {
      ret ~= Coord(x - 1, y);
      if (y > 0) ret ~= Coord(x - 1, y - 1);
    }
    if (y > 0) ret ~= Coord(x, y - 1);
    if (y < x) ret ~= Coord(x, y + 1);
    if (y < N - 1) {
      ret ~= Coord(x + 1, y);
      ret ~= Coord(x + 1, y + 1);
    }

    return ret;
  }

  Coord[] down() {
    Coord[] ret;
    if (y < N - 1) {
      ret ~= Coord(x + 1, y);
      ret ~= Coord(x + 1, y + 1);
    }
    return ret;
  }

  Coord[] up() {
    Coord[] ret;
    if (x > 0) {
      if (y < x) ret ~= Coord(x - 1, y);
      if (y > 0) ret ~= Coord(x - 1, y - 1);
    }
    return ret;
  }
}

struct State {
  int[][] balls;
  Swap[] swaps;
  Coord[] coords;

  this(int[][] b) {
    balls = b.map!"a.dup".array;
    coords = new Coord[](N * (N + 1) / 2);
    foreach(x; 0..N) foreach(y; 0..x + 1) {
      coords[b[x][y]] = Coord(x, y);
    }
  }

  int at(int x, int y) {
    return balls[x][y];
  }

  int at(Coord c) {
    return balls[c.x][c.y];
  }

  void add(Swap s) {
    auto from = balls[s.fx][s.fy];
    auto to = balls[s.tx][s.ty];
    s.exec(balls);
    swaps ~= s;
    swap(coords[from], coords[to]);
  }

  int score() {
    int e;
    foreach(x; 0..N - 1) foreach(y; 0..x + 1) {
      if (balls[x][y] > balls[x + 1][y]) e++;
      if (balls[x][y] > balls[x + 1][y + 1]) e++;
    }

    if (e > 0) {
      return 50000 - 50*e;
    } else {
      return 100000 - 5*swaps.length.to!int;
    }
  }

  void output() {
    if (swaps.length > 10000) swaps.length = 10000;

    swaps.length.writeln;
    foreach(s; swaps) {
      writefln("%s %s %s %s", s.fx, s.fy, s.tx, s.ty);
    }
  }
}


void problem() {
  auto B = new int[][](N, N);
  foreach(ref b; B) b[] = -1;
  foreach(i; 0..N) {
    foreach(j; 0..i + 1) B[i][j] = scan!int;
  }
  auto RND = Xorshift(unpredictableSeed);
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  int border(int x) { return [0,1,3,6,10,15,21,28,36,45,55,66,78,91,105 ,120 ,136 ,153 ,171 ,190 ,210 ,231 ,253 ,276 ,300 ,325 ,351 ,378 ,406 ,435,999][x]; }

  auto solve() {
    auto bestState = State(B);
    
    while(!elapsed(200)) {
      auto state = State(B);
      
      foreach(n; 0..N*(N + 1) / 2) {
        while(true) {
          auto from = state.coords[n];
          Coord to;
          int maxi = n;
          foreach(up; from.up) {
            if (maxi.chmax(state.at(up))) to = up;
          }

          if (maxi == n) {
            break;
          } else {
            state.add(Swap(from, to));
          }
        }
      }

      if (bestState.score < state.score) bestState = state;
    }

    bestState.output;
    stderr.writefln("Score = %s", bestState.score);
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
