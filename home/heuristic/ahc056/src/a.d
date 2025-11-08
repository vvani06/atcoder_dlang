void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int K = scan!int;
  int T = scan!int;
  bool[][] V = scan!string(N).map!(s => s.map!(c => c == '0').array).array;
  bool[][] H = scan!string(N - 1).map!(s => s.map!(c => c == '0').array).array;
  int[][] XY = scan!int(2 * K).chunks(2).array;

  int id(int r, int c) { return r * N + c; }
  string dirForAns(int dir) { return "LURDS"[dir..dir + 1]; }

  struct Coord {
    int r, c;

    int id() { return r * N + c; }
  }

  BitArray[] walkable = iota(N^^2).map!(_ => BitArray(false.repeat(4).array)).array;
  foreach(r; 0..N) foreach(c; 0..N) {
    if (c > 0) walkable[r * N + c][0] = V[r][c - 1];
    if (r > 0) walkable[r * N + c][1] = H[r - 1][c];
    if (c < N - 1) walkable[r * N + c][2] = V[r][c];
    if (r < N - 1) walkable[r * N + c][3] = H[r][c];
  }
  
  int[][] nextsFor = {
    int[][] ret = new int[][](N^^2, N^^2);
    foreach(gr; 0..N) foreach(gc; 0..N) {
      int goal = id(gr, gc);
      ret[goal][] = -1;
      ret[goal][goal] = 9;
      auto queue = DList!int([goal]);

      while(!queue.empty) {
        auto cur = queue.front;
        queue.removeFront();

        foreach(dir, d; zip(iota(4), [-1, -N, 1, N])) {
          if (!walkable[cur][dir]) continue;

          auto to = cur + d;
          if (ret[goal][to] == -1) {
            ret[goal][to] = (dir + 2) % 4;
            queue.insertBack(to);
          }
        }
      }
    }
    return ret;
  }();
  
  auto cur = id(XY[0][0], XY[0][1]);
  int[] steps;
  foreach(gr, gc; XY.asTuples!2) {
    auto goal = id(gr, gc);
    while(cur != goal) {
      auto dir = nextsFor[goal][cur];
      steps ~= dir;
      cur += [-1, -N, 1, N][dir];
    }
  }

  writefln("%s %s %s", 1, steps.length, steps.length);
  foreach(r; 0..N) {
    writefln("%(%s %)", 0.repeat(N));
  }
  foreach(i, s; steps) {
    writefln("%s %s %s %s %s", 0, i, 0, i + 1 == steps.length ? 0 : i + 1, dirForAns(s));
  }


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
  static if (is(T == float) || is(T == double) || is(T == float)) "%.16f".writefln(fn());
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

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}
