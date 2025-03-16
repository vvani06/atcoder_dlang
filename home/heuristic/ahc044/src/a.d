void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int L = scan!int;
  int[] T = scan!int(N);

  struct SimResult {
    int score;
    int[] deltas;
    int[] sortedDeltas;

    this(int score, int[] deltas) {
      this.score = score;
      this.deltas = deltas.dup;
      sortedDeltas = deltas.enumerate(0).array.sort!((a, b) => a[1] < b[1]).map!"a[0]".array;
    }

    auto frees(int n) {
      return sortedDeltas[0..n];
    }

    auto busys(int n) {
      return sortedDeltas[$ - n..$];
    }

    auto busyIndicies(int n, int[] graph) {
      auto b = busys(n).redBlackTree;
      return (2 * N).iota.filter!(i => graph[i] in b).array;
    }
  }

  class Sim {
    int turns;
    int[] goals;

    this(int l) {
      turns = l;
      goals = T.map!(t => (t * l) / L).array;
    }

    SimResult calcScore(int[] graph) {
      int[] worked = new int[](N);
      int worker;
      foreach(_; 0..turns) {
        worked[worker]++;
        worker = graph[worker * 2 + (worked[worker] % 2)^1];
      }

      auto deltas = zip(goals, worked).map!(x => x[1] - x[0]).array;
      return SimResult(deltas.map!"a.abs".sum, deltas);
    }
  }

  auto box = N.iota.map!(i => repeat(i, T[i]).array).joiner.array;
  int[] graph = new int[](2 * N);
  foreach(i; 0..N * 2) {
    graph[i] = box.choice(RND);
    // while(graph[i][0] == graph[i][1]) graph[i][1] = box.choice(RND);
  }

  auto sim = new Sim(500);
  auto bestSim = sim.calcScore(graph);
  auto bestScore = bestSim.score;
  auto bestGraph = graph.dup;

  int badCount;
  while(!elapsed(1900)) {
    foreach(_; 0..1) {
      auto target = bestSim.busyIndicies(10, graph).choice();
      graph[target] = bestSim.frees(10).choice(RND);
      // graph[target] = box.choice(RND);
    }

    auto res = sim.calcScore(graph);
    if (bestScore.chmin(res.score)) {
      bestSim = res;
      bestGraph = graph.dup;
      badCount = 0;
    } else {
      badCount++;
      if (badCount > 2) {
        badCount = 0;
        graph = bestGraph.dup;
      }
    }
  }

  foreach(ans; graph.chunks(2)) {
    writefln("%s %s", ans[0], ans[1]);
  }
}

// ----------------------------------------------

import std;
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
