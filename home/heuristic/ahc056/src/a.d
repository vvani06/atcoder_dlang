void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum int INF = int.max / 1000;

  int N = scan!int;
  int K = scan!int;
  int T = scan!int;
  bool[][] V = scan!string(N).map!(s => s.map!(c => c == '0').array).array;
  bool[][] H = scan!string(N - 1).map!(s => s.map!(c => c == '0').array).array;
  int[][] XY = scan!int(2 * K).chunks(2).array;

  int id(int r, int c) { return r * N + c; }
  string dirStr(int dir) { return "LURDS"[dir..dir + 1]; }
  int dirIndex(dchar d) { return "LURDS".countUntil(d).to!int; }
  int delta(dchar d) { return [-1, -N, 1, N][dirIndex(d)]; }

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

  struct Simulation {
    int[][] dirs;
    int[][] distances;

    this(bool[] blocked) {
      dirs = new int[][](N^^2, N^^2);
      distances = new int[][](N^^2, N^^2);

      foreach(gr; 0..N) foreach(gc; 0..N) {
        int goal = id(gr, gc);
        dirs[goal][] = -1;
        dirs[goal][goal] = 9;
        distances[goal][] = INF;
        distances[goal][goal] = 0;
        auto queue = DList!int([goal]);

        while(!queue.empty) {
          auto cur = queue.front;
          queue.removeFront();

          foreach(dir, d; zip(iota(4), [-1, -N, 1, N])) {
            if (!walkable[cur][dir]) continue;

            auto to = cur + d;
            if (blocked[to]) continue;

            if (dirs[goal][to] == -1) {
              dirs[goal][to] = (dir + 2) % 4;
              distances[goal][to] = distances[goal][cur] + 1;
              queue.insertBack(to);
            }
          }
        }
      }
    }

    int totalDistance() {
      int ret;
      auto cur = id(XY[0][0], XY[0][1]);
      foreach(gr, gc; XY[1..$].asTuples!2) {
        auto goal = id(gr, gc);
        ret += distances[goal][cur];
        cur = goal;
      }
      return ret;
    }
  }

  auto simulation = Simulation(false.repeat(N^^2).array);
  int[] route;
  string moves = {
    string ret;
    auto cur = id(XY[0][0], XY[0][1]);
    int currentState;
    foreach(gr, gc; XY[1..$].asTuples!2) {
      auto goal = id(gr, gc);

      while(cur != goal) {
        route ~= cur;
        auto dir = simulation.dirs[goal][cur];
        ret ~= dirStr(dir);
        cur += [-1, -N, 1, N][dir];
      }
      currentState++;
    }
    return ret;
  }();

  int tourSize = route.length.to!int;
  int bestScore = int.max;
  int bestColorSize;
  foreach(colorSize; 1..tourSize + 1) {
    int color;
    int state;

    foreach(node, dir, step; zip(route, moves, iota(tourSize))) {
      if (step < tourSize - 1 && ++color >= colorSize) {
        color %= colorSize;
        state++;
      }
    }

    if (bestScore.chmin(colorSize + state)) {
      bestColorSize = colorSize;
    }
  }
  
  alias Next = Tuple!(int, "color", int, "state", dchar, "dir");
  alias Key = Tuple!(int, "color", int, "state");
  Next[Key] bestFn;
  int[] bestColors;
  int bestStateSize;
  int best = int.max;

  foreach(colorSize; [bestColorSize]) {
    int[][] colors = new int[][](N^^2, 0);
    int[][] states = new int[][](N^^2, 0);
    int[] visited = new int[](N^^2);
    Next[Key] fn;
    int color;
    int state;
    foreach(node, dir, step; zip(route, moves, iota(tourSize))) {
      if (!colors[node].empty) {
        auto preKey = Key(colors[node].back, states[node].back);
        fn[preKey].color = color;
      }

      colors[node] ~= color;
      states[node] ~= state;
      auto key = Key(color, state);
      if (step < tourSize - 1 && ++color >= colorSize) {
        color %= colorSize;
        state++;
      }
      fn[key] = Next(0, state, dir);
      visited[node]++;
    }

    if (best.chmin(colorSize + state)) {
      bestFn = fn;
      bestColors = colors.map!(cs => cs.empty ? 0 : cs.front).array;
      bestStateSize = state + 1;
    }
  }

  writefln("%s %s %s", bestColorSize, bestStateSize, bestFn.length);
  foreach(col; bestColors.chunks(N)) writefln("%(%s %)", col);
  foreach(k, v; bestFn) {
    writefln("%s %s %s %s %s", k.color, k.state, v.color, v.state, v.dir);
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

K binarySearch(K)(bool delegate(K) cond, K l, K r) { return binarySearch((K k) => k, cond, l, r); }
T binarySearch(T, K)(K delegate(T) fn, bool delegate(K) cond, T l, T r) {
  auto ok = l;
  auto ng = r;
  const T TWO = 2;
 
  bool again() {
    static if (is(T == float) || is(T == double) || is(T == real)) {
      return !ng.approxEqual(ok, 1e-08, 1e-08);
    } else {
      return abs(ng - ok) > 1;
    }
  }
 
  while(again()) {
    const half = (ng + ok) / TWO;
    const halfValue = fn(half);
 
    if (cond(halfValue)) {
      ok = half;
    } else {
      ng = half;
    }
  }
 
  return ok;
}
