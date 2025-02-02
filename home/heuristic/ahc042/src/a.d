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

  Coord[] os, xs;
  foreach(r; 0..N) foreach(c; 0..N) {
    if (G[r][c] == 'o') os ~= new Coord(r, c);
    if (G[r][c] == 'x') xs ~= new Coord(r, c);
  }
  
  void move(int dir, int target, int step) {
    foreach(_; 0..step) writefln("%s %s", MOVE[dir..dir + 1], target);
    int[] orem, xrem;

    if (dir % 2 == 0) {
      int delta = dir == 0 ? -step : step;

      foreach(i, ref t; os) {
        if (t.c != target) continue;

        t.r += delta;
        if (t.r < 0 || t.r >= N) orem ~= i.to!int;
      }
      foreach(i, ref t; xs) {
        if (t.c != target) continue;

        t.r += delta;
        if (t.r < 0 || t.r >= N) xrem ~= i.to!int;
      }
    } else {
      int delta = dir == 1 ? -step : step;

      foreach(i, ref t; os) {
        if (t.r != target) continue;

        t.c += delta;
        if (t.c < 0 || t.c >= N) orem ~= i.to!int;
      }
      foreach(i, ref t; xs) {
        if (t.r != target) continue;

        t.c += delta;
        if (t.c < 0 || t.c >= N) xrem ~= i.to!int;
      }
    }

    if (!orem.empty) os = os.length.to!int.iota.filter!(t => !orem.canFind(t)).map!(t => os[t]).array;
    if (!xrem.empty) xs = xs.length.to!int.iota.filter!(t => !xrem.canFind(t)).map!(t => xs[t]).array;
  }

  while(!xs.empty) {
    xs.sort!((a, b) => a.outDistance < b.outDistance);

    auto x = xs[0];    
    move(x.outDir, x.outDir % 2 == 0 ? x.c : x.r, x.outDistance);
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
