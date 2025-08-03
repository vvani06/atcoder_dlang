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

    int dist(Coord other) {
      return (x - other.x)^^2 + (y - other.y)^^2;
    }
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

  enum TIME_LIMIT = 0;

  LIMIT: foreach(graphHeight; 1..8) {
    if (M < 2^^graphHeight) break;

    const totalNodeSize = 2^^(graphHeight + 1) - 1;
    const lastNodeSize = 2^^graphHeight;
    const sorterNodeSize = totalNodeSize - lastNodeSize;

    int[] bestLastGraph;
    int[][] graph = new int[][](totalNodeSize, 0);
    foreach(i; 0..2^^graphHeight - 1) graph[i] = [i*2 + 1, i*2 + 2];
    // foreach(i; 2^^(graphHeight - 1) - 1..2^^graphHeight - 1) graph[i + N] = graph[i + N].map!(a => a % N).array; 

    real bestScore = 0;
    int[] bestAssign;
    foreach(_; 0..50000) {
      if (elapsed(TIME_LIMIT)) break;
      auto assign = iota(sorterNodeSize).map!(_ => uniform(0, K, RND)).array;

      real[][] matrix = new real[][](lastNodeSize, N);
      foreach(item; 0..N) {
        real[] p = (0.0L).repeat(totalNodeSize).array;
        p[0] = 1.0;

        foreach(node, nexts, sorter; zip(iota(sorterNodeSize), graph, assign)) {
          if (nexts.empty) continue;

          p[nexts[0]] += p[node] * P[sorter][item];
          p[nexts[1]] += p[node] * (1.0 - P[sorter][item]);
        }

        foreach(node; 0..lastNodeSize) {
          matrix[node][item] = p[sorterNodeSize + node];
        }
      }

      real score = 0;
      int[] lastGraph;
      foreach(node; 0..lastNodeSize) {
        lastGraph ~= matrix[node].maxIndex.to!int;
        score += matrix[node].maxElement;
      }
        
      if (bestScore.chmax(score)) {
        bestAssign = assign;
        bestLastGraph = lastGraph;
      }
    }

    if (bestScore <= 0) continue;

    // deb((N - bestScore) * (10000 / N));
    // bestAssign.deb;
    graph = (new int[](0)).repeat(N).array ~ graph[0..sorterNodeSize].map!(s => s.map!(n => n < sorterNodeSize ? n + N : bestLastGraph[n - sorterNodeSize]).array).array;
    graph ~= (new int[](0)).repeat(N + M - graph.length).array;
    // graph.deb;

    Coord[] coords = D.map!(c => Coord(c[0], c[1])).array ~ S.map!(c => Coord(c[0], c[1])).array ~ Coord(0, 5000);
    int[] nodeMap = iota(N + M).array;

    bool isOk;
    MAIN: foreach(_; 0..200000) {
      if (elapsed(TIME_LIMIT)) break LIMIT;
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
        sorts[m - N] = [bestAssign[i - N], nodeMap[graph[i][0]], nodeMap[graph[i][1]]];
      }
      bestAns ~= sorts;
    }
  }

  foreach(s; bestAns) {
    // writefln("%(%s %)", s);
  }

  Coord[] coords = D.map!(c => Coord(c[0], c[1])).array ~ S.map!(c => Coord(c[0], c[1])).array ~ Coord(0, 5000);
  struct Edge {
    int a, b;

    bool cross(Edge other) {
      return intersect(coords[a], coords[b], coords[other.a], coords[other.b]);
    }
  }

  {
    Edge[] edges;
    int startNode;
    {
      foreach(s; iota(N, N+M).array.sort!((a, b) => coords[$ - 1].dist(coords[a]) < coords[$ - 1].dist(coords[b]))) {
        auto newEdge = Edge(s, N + M);
        edges ~= newEdge;
        startNode = s;
        break;
      }
      bool[] used = new bool[](N + M);
      used[0..N] = true;
      int[] queue = [startNode];
      foreach(depth; 0..2) {
        bool[int] nexts;
        foreach(n; queue) used[n] = true;

        foreach(cur; queue) {
          int conn;
          auto sorted = iota(N, N+M).array.sort!((a, b) => coords[cur].dist(coords[a]) < coords[cur].dist(coords[b])).array;
          foreach(next; sorted[0..$]) {
            if (conn >= 2) break;
            if (cur == next || (next >= N && used[next])) continue;

            auto newEdge = Edge(cur, next);
            if (edges.any!(e => e.cross(newEdge))) continue;

            edges ~= newEdge;
            if (next >= N) {
              nexts[next] = true;
              used[next] = true;
            }
            conn++;
          }
        }
        queue = nexts.keys;
      }

      int[] connected = new int[](N);
      foreach(cur; queue) {
        int conn;
        foreach(next; iota(N).array.sort!((a, b) => connected[a] < connected[b])) {
          if (conn >= 2) break;

          auto newEdge = Edge(cur, next);
          if (edges.any!(e => e.cross(newEdge))) continue;

          edges ~= newEdge;
          conn++;
          connected[next]++;
        }
      }
    }

    int[][] graph = new int[][](N + M, 0);
    foreach(e; edges[1..$]) graph[e.a] ~= e.b;
    foreach(e; edges[1..$]) graph[e.a] ~= e.b;

    auto sorted = topologicalSort(graph);
    sorted.deb;
    int[] bestAssign;
    real bestScore = 0;
    foreach(_; 0..5000) {
      int[] assign = new int[](N + M);
      foreach(i; N..N + M) assign[i] = uniform(0, K, RND);

      real[][] matrix;
      foreach(item; 0..N) {
        real[] p = new real[](N + M);
        p[] = 0;
        p[startNode] = 1;
        foreach(cur; sorted) {
          if (cur < N || graph[cur].empty) continue;

          auto v1 = graph[cur][0];
          auto v2 = graph[cur][1];
          p[v1] += p[cur] * P[assign[cur]][item];
          p[v2] += p[cur] * (1.0 - P[assign[cur]][item]);
        }
        matrix ~= p[0..N];
      }

      real score = 0;
      assign[0..N] = -1;
      auto rbt = N.iota.redBlackTree;
      foreach(p, item, node; iota(N^^2).map!(n => tuple(matrix[n / N][n % N], n / N, n % N)).array.sort!"a > b") {
        if (!(item in rbt) || assign[node] != -1) continue;

        rbt.removeKey(item);
        score += p;
        assign[node] = item;
      }

      foreach(i; 0..N) {
        if (assign[i] == -1) {
          assign[i] = rbt.front;
          rbt.removeFront();
        }
      }
      if (bestScore.chmax(score)) {
        bestAssign = assign;
      }
    }

    deb((N - bestScore) * (1000 / N));

    writefln("%(%s %)", bestAssign[0..N]);
    writefln("%(%s %)", [startNode]);

    foreach(k, sw; zip(bestAssign[N..$], graph[N..$])) {
      if (sw.empty) {
        writeln("-1");
      } else {
        writefln("%(%s %)", (k ~ sw)[0..3]);
      }
    }
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

int[] topologicalSort(int[][] g) {
  auto size = g.length.to!int;
  auto depth = new int[](size);
  foreach(e; g) foreach(p; e) depth[p]++;

  auto q = heapify!"a > b"(new int[](0));
  foreach(i; 0..size) if (depth[i] == 0) q.insert(i);

  int[] sorted;
  while(!q.empty) {
    auto p = q.front;
    q.removeFront;
    foreach(n; g[p]) {
      depth[n]--;
      if (depth[n] == 0) q.insert(n);
    }

    sorted ~= p;
  }

  return sorted;
}

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}
