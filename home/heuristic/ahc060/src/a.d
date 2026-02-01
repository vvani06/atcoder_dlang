void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;
  enum TIME_LIMIT = 1800;

  int N = scan!int;
  int M = scan!int;
  int K = scan!int;
  int T = scan!int;
  int[][] E = scan!int(2 * M).chunks(2).array;

  int[][] graph = new int[][](N, 0);
  foreach(u, v; E.asTuples!2) {
    graph[u] ~= v;
    graph[v] ~= u;
  }

  int[][][] rests = new int[][][](N, N, 0);
  rests[0][0] = graph[0];
  foreach(node; 0..N) {
    foreach(u; graph[node]) foreach(v; graph[node]) {
      if (u != v) rests[node][u] ~= v;
    }
  }

  bool isShop(int node) {
    return node < K;
  }

  class Sim {
    bool[BitArray][] stocks;
    bool[] isRed;
    int[][] ans;
    int STEP_LIMIT;
    Path[][] pathes;
    bool initiated;

    int pathIndex(int from, int to, int step) { return step * K^^2 + to * K + from; }

    struct Path {
      int start, end;
      int[] route;

      BitArray asIce(Sim sim) {
        if (route.length <= 1) return BitArray(new bool[](0));

        int cur = start;
        bool[] ice = new bool[](route.length - 1);
        foreach(i, next; route[0..$ - 1]) {
          ice[i] = sim.isRed[next];
          cur = next;
        }
        return BitArray(ice);
      }

      bool hasValue(Sim sim) {
        return (asIce(sim) in sim.stocks[end]) is null;
      }

      bool availableFrom(int from) {
        return route[0] != from;
      }
    }

    this(int limit) {
      stocks.length = K;
      isRed = new bool[](N);
      STEP_LIMIT = limit;
      pathes = new Path[][](K * K * STEP_LIMIT, 0);

      foreach(from; 0..K) {
        DList!int route;
        void dfs(int cur, int pre, int step) {
          if (elapsed(TIME_LIMIT)) return;
          if (step >= STEP_LIMIT) return;

          foreach(next; cur == pre ? graph[cur] : rests[cur][pre]) {
            route.insertBack(next);
            if (isShop(next)) {
              pathes[pathIndex(from, next, step)] ~= Path(from, next, route.array);
            } else {
              dfs(next, cur, step + 1);
            }
            route.removeBack();
          }
        }
        dfs(from, from, 0);
      }

      initiated = true;
    }

    void simulate() {
      if (!initiated) return;

      int moves;
      int from, pre;
      while(moves < T) {
        if (elapsed(TIME_LIMIT)) return;
        
        auto tos = iota(K).array.randomCover(RND);
        Path chosen;

        MAIN: foreach(step; 0..STEP_LIMIT) {
          foreach(to; tos) {
            auto ps = pathes[pathIndex(from, to, step)];
            foreach(path; ps.randomSample(min(50, ps.length), RND)) {
              if (!path.availableFrom(pre)) continue;

              chosen = path;
              if (path.hasValue(this)) {
                break MAIN;
              }
            }
          }
        }

        if (chosen.route.empty) break;

        auto valuable = chosen.hasValue(this);
        pre = chosen.route.length == 1 ? from : chosen.route[$ - 2];
        from = chosen.end;
        stocks[chosen.end][chosen.asIce(this)] = true;

        auto ansRoute = chosen.route.dup;
        if (!valuable) {
          auto flipCandidate = chosen.route[0..$ - 1].filter!(i => !isRed[i]).array;
          if (!flipCandidate.empty) {
            auto flipNode = flipCandidate.choice(RND);
            isRed[flipNode] = true;
            foreach_reverse(i, node; ansRoute) {
              if (node == flipNode) {
                ansRoute = ansRoute[0..i + 1] ~ (-1) ~ ansRoute[i + 1..$];
                break;
              }
            }
          }
        }

        moves += ansRoute.length.to!int;
        if (moves <= T) ans ~= ansRoute;
      }
    }

    size_t score() {
      return stocks.map!"a.values.length".sum;
    }

    void outputAsAns() {
      foreach(a; ans) writefln("%(%s %)", a);
    }
  }
  
  Sim bestSim = new Sim(0);
  foreach(stepSize; 8..25) {
    if (elapsed(TIME_LIMIT)) break;

    auto sim = new Sim(stepSize);
    sim.simulate();
    if (bestSim.score < sim.score) {
      bestSim = sim;
    }
  }
  bestSim.outputAsAns();
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
