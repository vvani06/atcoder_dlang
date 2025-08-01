void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  struct Coord {
    int x, y;
  }

  bool intersect(ref Coord p1, ref Coord p2, ref Coord q1, ref Coord q2) {
    if (p1 == q1 || p1 == q2 || p2 == q1 || p2 == q2) return false;
    if (max(p1.x, p2.x) < min(q1.x, q2.x) ||
        max(q1.x, q2.x) < min(p1.x, p2.x) ||
        max(p1.y, p2.y) < min(q1.y, q2.y) ||
        max(q1.y, q2.y) < min(p1.y, p2.y))
        return false;

    int sign(int v) {
      return v > 0 ? 1 : v < 0 ? -1 : 0;
    }

    int orientation(ref Coord a, ref Coord b, ref Coord c) {
      return sign((b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x));
    }

    auto o1 = orientation(p1, p2, q1);
    auto o2 = orientation(p1, p2, q2);
    auto o3 = orientation(q1, q2, p1);
    auto o4 = orientation(q1, q2, p2);
    return (o1 * o2 <= 0) && (o3 * o4 <= 0);
  }

  int N = scan!int;
  int M = scan!int;
  int K = scan!int;
  int[][] D = scan!int(2 * N).chunks(2).array;
  int[][] S = scan!int(2 * M).chunks(2).array;
  real[][] P = scan!real(K * N).chunks(N).array;

  int[][] bestAns;
  real bestAnsScore = 0;

  LIMIT: foreach(graphHeight; 1..4) {
    int[][] graph = new int[][](M + N, 0);
    foreach(i; 0..2^^graphHeight - 1) graph[i + N] = [i*2 + 1 + N, i*2 + 2 + N];
    foreach(i; 2^^(graphHeight - 1) - 1..2^^graphHeight - 1) graph[i + N] = graph[i + N].map!(a => a % N).array; 

    real bestScore = 0;
    real[] bestScores;
    int[] bestAssign;
    foreach(_; 0..50000) {
      if (elapsed(1500)) break;
      auto assign = (-1).repeat(N).array ~ M.iota.map!(_ => uniform(0, K, RND)).array;

      real[] scores;
      foreach(item; 0..N) {
        real[] p = (0.0L).repeat(N + M).array;
        p[N] = 1.0;

        foreach(node, nexts, sorter; zip(iota(N + M), graph, assign)) {
          if (nexts.empty) continue;

          p[nexts[0]] += p[node] * P[sorter][item];
          p[nexts[1]] += p[node] * (1.0 - P[sorter][item]);
        }
        scores ~= p[item];
      }
        
      if (bestScore.chmax(scores.sum)) {
        bestAssign = assign;
        bestScores = scores;
      }
    }

    bestScore.deb;
    bestScores.deb;
    bestAssign[N..$].deb;

    Coord[] coords = D.map!(c => Coord(c[0], c[1])).array ~ S.map!(c => Coord(c[0], c[1])).array ~ Coord(0, 5000);
    int[] nodeMap = iota(N + M).array;

    bool isOk;
    MAIN: foreach(_; 0..200000) {
      if (elapsed(1900)) break LIMIT;
      nodeMap[0..N].randomShuffle(RND);
      nodeMap[N..$].randomShuffle(RND);

      int[][] lines = [[N + M, nodeMap[N]]];
      foreach(i; N..N + M) {
        if (graph[i].empty) continue;

        auto from = nodeMap[i];
        auto to1 = nodeMap[graph[i][0]];
        lines ~= [from, to1];
        auto to2 = nodeMap[graph[i][1]];
        lines ~= [from, to2];
      }

      // lines.deb;
      foreach(i; 0..lines.length - 1) foreach(j; i + 1..lines.length) {
        if (intersect(coords[lines[i][0]], coords[lines[i][1]], coords[lines[j][0]], coords[lines[j][1]])) continue MAIN;
      }
      
      isOk = true;
      break;
    }

    if (isOk && bestAnsScore.chmax(bestScore)) {
      bestAns.length = 0;
      bestAns ~= N.iota.map!(i => nodeMap.countUntil(i).to!int).array;
      bestAns ~= [nodeMap[N]];

      int[][] sorts = [-1].repeat(M).array;
      foreach(i; N..N + M) {
        if (graph[i].empty) continue;
        
        auto m = nodeMap[i];
        sorts[m - N] = [bestAssign[i], nodeMap[graph[i][0]], nodeMap[graph[i][1]]];
      }
      bestAns ~= sorts;
    }
  }

  foreach(s; bestAns) {
    writefln("%(%s %)", s);
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

