void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int M = scan!int;
  int V = scan!int;
  bool[][] S = scan!string(N).map!(s => s.map!(c => c == '1').array).array;
  bool[][] T = scan!string(N).map!(s => s.map!(c => c == '1').array).array;

  struct Coord {
    int r, c;

    int dist(inout Coord other) {
      return abs(r - other.r) + abs(c - other.c);
    }

    inout int opCmp(inout Coord other) {
      return cmp(
        [r, c],
        [other.r, other.c]
      );
    }
  }

  V.writeln;
  writefln("%s %s", 0, 1);
  const pickers = V - 2;
  foreach(v; 0..pickers) {
    writefln("%s %s", 1, 1);
  }
  Coord cur = Coord(N / 2, N / 2);
  writefln("%s %s", cur.r, cur.c);

  writefln("%s%s%s", "..", 'R'.repeat(V - 2).to!string, '.'.repeat(V).to!string);
  writefln("%s%s%s", "..", 'R'.repeat(V - 2).to!string, '.'.repeat(V).to!string);

  auto toPick = new Coord[](0).redBlackTree;
  auto toDrop = new Coord[](0).redBlackTree;

  foreach(r; 0..N) foreach(c; 0..N) {
    if (!(S[r][c] ^ T[r][c])) continue;

    if (S[r][c]) {
      toPick.insert(Coord(r, c));
    } else {
      toDrop.insert(Coord(r, c));
    }
  }

  int pickedCount;
  while(!toDrop.empty) {
    int minDist = int.max;
    Coord coord;
    bool pick;

    if (pickedCount < pickers) foreach(c; toPick) {
      if (minDist.chmin(cur.dist(c))) {
        coord = c;
        pick = true;
      }
    }

    if (pickedCount > 0) foreach(c; toDrop) {
      if (minDist.chmin(cur.dist(c))) {
        coord = c;
        pick = false;
      }
    }

    char[][] moves;
    foreach(_; 0..abs(cur.r - coord.r)) {
      moves ~= (cur.r > coord.r ? 'U' : 'D') ~ '.'.repeat(2*V - 1).array;
    }
    foreach(_; 0..abs(cur.c - coord.c)) {
      moves ~= (cur.c > coord.c ? 'L' : 'R') ~ '.'.repeat(2*V - 1).array;
    }
    if (moves.empty) {
      moves ~= '.'.repeat(2*V).array;
    }

    moves[$ - 1][$ - V + 2 + pickedCount - !pick] = 'P';
    if (pick) {
      pickedCount++;
      toPick.removeKey(coord);
    } else {
      pickedCount--;
      toDrop.removeKey(coord);
    }

    cur = coord;
    foreach(m; moves) m.writeln;
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
