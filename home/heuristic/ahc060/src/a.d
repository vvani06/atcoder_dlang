void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

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

  bool[BitArray][] stocks;
  stocks.length = K;

  bool isShop(int node) {
    return node < K;
  }

  bool[] isRed = new bool[](N);
  struct Path {
    int start, end;
    int[] route;

    BitArray asIce() {
      if (route.length <= 1) return BitArray(new bool[](0));

      int cur = start;
      bool[] ice = new bool[](route.length - 1);
      foreach(i, next; route[0..$ - 1]) {
        ice[i] = isRed[next];
        cur = next;
      }
      return BitArray(ice);
    }

    bool hasValue() {
      return (asIce in stocks[end]) is null;
    }

    bool availableFrom(int from) {
      return route[0] != from;
    }
  }

  enum STEP_LIMIT = 13;
  int pathIndex(int from, int to, int step) { return step * K^^2 + to * K + from; }
  auto pathes = new Path[][](K * K * STEP_LIMIT, 0);

  foreach(from; 0..K) {
    DList!int route;
    void dfs(int cur, int pre, int step) {
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

  int[][] ans;
  int moves;
  int from, pre;
  while(moves < T) {
    auto tos = iota(K).array.randomCover(RND);
    Path chosen;

    MAIN: foreach(step; 0..STEP_LIMIT) {
      foreach(to; tos) {
        auto ps = pathes[pathIndex(from, to, step)];
        foreach(path; ps.randomSample(min(50, ps.length), RND)) {
          if (!path.availableFrom(pre)) continue;

          chosen = path;
          if (path.hasValue) {
            break MAIN;
          }
        }
      }
    }

    if (chosen.route.empty) {
      break;
    }

    auto valuable = chosen.hasValue;
    pre = chosen.route.length == 1 ? from : chosen.route[$ - 2];
    from = chosen.end;
    stocks[chosen.end][chosen.asIce] = true;

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

    if (moves <= T) {
      ans ~= ansRoute;
    }
  }

  foreach(a; ans) {
    writefln("%(%s %)", a);
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
