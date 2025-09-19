void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int TR = scan!int;
  int TC = scan!int;
  dchar[][] G = scan!string(N).map!"a.array".array;

  struct Coord {
    int r, c;

    T of(T)(T[][] matrix) {
      return matrix[r][c];
    }

    int asId() {
      return r * 50 + c;
    }

    bool valid() {
      return min(r, c) >= 0 && max(r, c) < N;
    }

    int[] asArray() {
      return [r, c];
    }
  }

  Coord GOAL = Coord(TR, TC);
  Coord START = Coord(0, N / 2);

  bool reachable(Coord start, bool[][] blocked) {
    bool[][] visited = new bool[][](N, N);
    visited[start.r][start.c] = true;
    for (auto queue = DList!Coord([start]); !queue.empty;) {
      auto cur = queue.front;
      queue.removeFront;
      if (cur == GOAL) return true;
      
      foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
        auto r = dr + cur.r;
        auto c = dc + cur.c;
        if (min(r, c) < 0 || max(r, c) >= N) continue;
        if (visited[r][c] || blocked[r][c]) continue;

        visited[r][c] = true;
        queue.insertBack(Coord(r, c));
      }
    }
    return false;
  }

  Coord[] aroundDist(Coord base, int distance) {
    Coord[] ret;
    foreach(r; iota(-distance, distance + 1)) {
      auto c = distance - abs(r);
      ret ~= Coord(base.r + r, base.c + c);
      if (c > 0) ret ~= Coord(base.r + r, base.c - c);
    }
    return ret.filter!(c => c.valid).array;
  }

  bool[][] visited = new bool[][](N, N);
  bool[][] blocked = new bool[][](N, N);
  foreach (r; 0..N) foreach (c; 0..N) blocked[r][c] = G[r][c] == 'T';
  blocked[START.r][START.c] = true;

  Coord[] blocksToAdd;
  foreach(d; iota(1, N * 2, 3)) {
    auto toBlock = aroundDist(GOAL, d);

    REM: foreach(rem; 1..min(toBlock.length + 1, N)) {
      foreach(_; 0..100) {
        auto testBlocked = blocked.map!"a.dup".array;
        auto candidates = toBlock.randomSample(toBlock.length - rem, RND);
        foreach(coord; candidates) testBlocked[coord.r][coord.c] = true;

        if (reachable(START, testBlocked)) {
          foreach(coord; candidates) {
            if (!blocked[coord.r][coord.c]) blocksToAdd ~= coord;
            blocked[coord.r][coord.c] = true;
          }
          break REM;
        }
      }
    }
  }

  foreach (turn; 0..int.max) {
    int PR = scan!int;
    int PC = scan!int;
    int NV = scan!int;
    int[][] V = scan!int(NV * 2).chunks(2).array;
    if (PR == TR && PC == TC) break;

    foreach (r, c; V.asTuples!2) visited[r][c] = true;

    if (turn == 0) {
      writefln("%s %(%s %)", blocksToAdd.length, blocksToAdd.map!"a.asArray".joiner);
    } else {
      writeln(0);
    }
    stdout.flush();
  }
}

// ----------------------------------------------

import std;
import core.bitop;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(lazy T t){ debug { stderr.write("# "); stderr.writeln(t); }}
void debf(T ...)(lazy T t){ debug { stderr.write("# "); stderr.writefln(t); }}
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
