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

  int id(int r, int c) { return r * N + c; }

  bool[][] V = scan!string(N).map!(s => s.map!(c => c == '0').array).array;
  bool[][] H = scan!string(N - 1).map!(s => s.map!(c => c == '0').array).array;
  int[][] XY = scan!int(2 * K).chunks(2).array;
  int[] XYI = XY.map!(xy => id(xy[0], xy[1])).array;

  const DELTA = [-1, -N, 1, N];
  const DIR_DELTA = [-1: 'L', -N: 'U', 1: 'R', N: 'D'];
  const DIRS = "LURDS";

  alias DirState = Tuple!(dchar, "dir", int, "state");
  alias DirStatesPerNode = Tuple!(int, "node", DirState[], "dirStates");

  BitArray[] walkable = iota(N^^2).map!(_ => BitArray(false.repeat(4).array)).array;
  foreach(r; 0..N) foreach(c; 0..N) {
    if (c > 0) walkable[r * N + c][0] = V[r][c - 1];
    if (r > 0) walkable[r * N + c][1] = H[r - 1][c];
    if (c < N - 1) walkable[r * N + c][2] = V[r][c];
    if (r < N - 1) walkable[r * N + c][3] = H[r][c];
  }

  struct Route {
    int visitedCost;
    int[] availableMoves;

    enum int moveCost = 10;
    int[][] dirs;
    int[][] distances;
    int[] visitCount;

    int[] route;
    int[] moves;

    // int calcId;
    // int[400][4] calced;
    // Queue[400][4] froms;
    // int[400][4] costs;

    this(int visitedCost, int[] availableMoves) {
      dirs = new int[][](N^^2, N^^2);
      distances = new int[][](N^^2, N^^2);
      visitCount = new int[](N^^2);
      this.visitedCost = visitedCost;
      this.availableMoves = availableMoves;

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
            if (dirs[goal][to] == -1) {
              dirs[goal][to] = (dir + 2) % 4;
              distances[goal][to] = distances[goal][cur] + 1;
              queue.insertBack(to);
            }
          }
        }
      }
    }

    int length() {
      int ret;
      auto cur = id(XY[0][0], XY[0][1]);
      foreach(gr, gc; XY[1..$].asTuples!2) {
        auto goal = id(gr, gc);
        ret += distances[goal][cur];
        cur = goal;
      }
      return ret;
    }

    DirStatesPerNode[] dirStatesPerNode() {
      DirStatesPerNode[] ret = iota(N^^2).map!(node => DirStatesPerNode(node, new DirState[](0))).array;

      auto cur = id(XY[0][0], XY[0][1]);
      int step;
      foreach(gr, gc; XY[1..$].asTuples!2) {
        auto goal = id(gr, gc);

        while(cur != goal) {
          auto dir = dirs[goal][cur];
          ret[cur].dirStates ~= DirState(DIRS[dir], step);
          cur += [-1, -N, 1, N][dir];
          step++;
        }
      }
      return ret;
    }

    int walk(int start, int startDir, int goal) {
      alias Queue = Tuple!(int, "node", int, "dir", int, "cost");

      Queue[][] froms = new Queue[][](N^^2, 4);
      int[][] costs = new int[][](N^^2, 4);
      foreach(ref c; costs) c[] = INF;
      costs[start][startDir] = 0;
      froms[start][startDir] = Queue(start, startDir, 0);

      auto queue = [Queue(start, startDir, 0)].heapify!"a.cost > b.cost";
      while (!queue.empty) {
        auto cur = queue.front;
        if (costs[cur.node][cur.dir] != cur.cost) continue;

        if (cur.node == goal) break;
        queue.removeFront();

        foreach(dd; availableMoves) {
          auto turned = (cur.dir + dd) % 4;
          auto to = cur.node + (walkable[cur.node][turned] ? DELTA[turned] : 0);

          auto cost = cur.cost + moveCost + visitCount[to]*visitedCost;
          if (costs[to][turned].chmin(cost)) {
            froms[to][turned] = cur;
            queue.insert(Queue(to, turned, cost));
          }
        }
      }

      if (queue.empty) return -1;
      auto node = goal;
      auto dir = queue.front.dir;
      DList!int backtrack;
      DList!int backtrackMove;
      while (!(node == start && dir == startDir)) {
        visitCount[node]++;
        backtrack.insertFront(node);
        backtrackMove.insertFront((dir + 4 - froms[node][dir].dir) % 4);

        auto nn = froms[node][dir].node;
        dir = froms[node][dir].dir;
        node = nn;
      }
      backtrack.insertFront(node);
      backtrackMove.insertFront((dir + 4 - froms[node][dir].dir) % 4);

      route ~= backtrack.array[0..$ - 1];
      moves ~= backtrackMove.array[1..$];
      return queue.front.dir;
    }
  }

  // ----------------------------------------------------------------------------------------------------

  struct Ans {
    int colorCount, stateCount;
    int[] colors;
    string[] fn;

    const int score() { return colorCount + stateCount; }

    void outputAsAns() {
      writefln("%s %s %s", colorCount, stateCount, fn.length);
      foreach(col; colors.chunks(N)) writefln("%(%s %)", col);
      foreach(f; fn) writeln(f);
    }

    inout int opCmp(inout Ans other) {
      return cmp([score()], [other.score()]);
    }
  }

  Ans[] candidates;

  // ----------------------------------------------------------------------------------------------------

  // sqrt(最短ルート) * 2 のスコアをほぼ保証できるやつ 基本解とする
  candidates ~= {
    auto route = Route(0, []);
    route.length.deb;
    auto dirStatesPerNode = route.dirStatesPerNode();
    // dirStatesPerNode.each!deb;
    
    alias Next = Tuple!(int, "color", int, "state", dchar, "dir");
    alias Key = Tuple!(int, "color", int, "state");
    Next[Key] bestFn;
    int[] bestColors;
    int bestColorSize, bestStateSize;
    int best = int.max;
    
    int[] stateSizes = [18];
    stateSizes = iota(route.length.to!real.sqrt.to!int / 2, route.length.to!real.sqrt.to!int * 2).array;
    foreach(stateSize; stateSizes) {
      int[] nextColorByState = new int[](stateSize);
      int[][] colorByNode = new int[][](N^^2, 0);
      Next[Key] fn;

      DirState[] sequence;
      int[] graph = new int[](route.length);
      graph[] = -1;
      int[] graphColor = new int[](route.length);
      int[][] revGraph = new int[][](route.length, 0);
      int[][DirState] dsSeqs;
      int[][] indicesByNode = new int[][](N^^2, 0);

      int addNode(DirState ds, int color) {
        auto index = sequence.length.to!int;
        sequence ~= ds;
        dsSeqs[ds] ~= index;
        graphColor[index] = color;
        return index;
      }

      void addEdge(int u, int v) {
        graph[u] = v;
        revGraph[v] ~= u;
      }

      int findGraph(DirState[] dss) {
        if (dss.empty) return 0;
        if (!(dss.front in dsSeqs)) return -1;

        int gl = dss.length.to!int;
        bool dfs(int cur, int step) {
          if (step == gl) return true;

          auto next = graph[cur];
          if (next >= 0 && sequence[next] == dss[step] && dfs(graph[cur], step + 1)) return true;
          return false;
        }

        foreach(from; dsSeqs[dss.front]) {
          if (dfs(from, 1)) return from;
        }
        return -1;
      }

      foreach(dsn; dirStatesPerNode.sort!"a.dirStates.length > b.dirStates.length") {
        auto node = dsn.node;
        auto preKey = Key(-1, -1);
        int preIndex;
        auto dirStates = dsn.dirStates.map!(ds => DirState(ds.dir, ds.state % stateSize)).array;

        foreach(dsi, ds; dirStates) {
          auto reusable = findGraph(dirStates[dsi..$]);
          if (reusable >= 0) {
            auto color = graphColor[reusable];
            colorByNode[node] ~= color;
            if (preKey.color != -1) {
              fn[preKey].color = color;
              addEdge(preIndex, reusable);
            }
            
            break;
          }

          auto state = ds.state % stateSize;
          auto color = nextColorByState[state];
          colorByNode[node] ~= color;
          nextColorByState[state]++;
          auto index = addNode(ds, color);
          indicesByNode[node] ~= index;

          auto key = Key(color, state);
          fn[key] = Next(0, (state + 1) % stateSize, ds.dir);
          if (preKey.color != -1) {
            fn[preKey].color = color;
            addEdge(preIndex, index);
          }
          preKey = key;
          preIndex = index;
        }
      }

      auto colorSize = nextColorByState.maxElement;
      auto score = colorSize + stateSize;
      if (best.chmin(score)) {
        bestColorSize = colorSize;
        bestStateSize = stateSize;
        bestFn = fn;
        bestColors = colorByNode.map!(colors => colors.empty ? 0 : colors.front).array;
      }
    }

    string[] fns;
    foreach(k, v; bestFn) {
      fns ~= format("%s %s %s %s %s", k.color, k.state, v.color, v.state, v.dir);
    }
    return Ans(bestColorSize, bestStateSize, bestColors, fns);
  }();


  // ----------------------------------------------------------------------------------------------------
  // state で向きを、color で方向転換を表現するやつ ムラがありすぎるが稀に強い

  foreach(visitedCost; [10, 0, 20, 30, 40, 50, 100]) {
  if (elapsed(1900)) break;
  BASE: foreach(baseMove; [[0, 1], [0, 3], [0, 1, 3], [0, 1, 2], [0, 2, 3], [0, 1, 2, 3]]) {
    if (elapsed(1900)) break;
    deb("----------------------------------------------------------------------------------------------------");
    deb("cost = ", visitedCost, ", moves = ", baseMove);
    deb("----------------------------------------------------------------------------------------------------");

    auto route = Route(visitedCost, baseMove);
    int currentDir;
    foreach(i; 0..K - 1) {
      currentDir = route.walk(XYI[i], currentDir, XYI[i + 1]);
      if (currentDir == -1) continue BASE;
    }

    if (route.route.length > T) continue BASE;

    int[][] movesByNode = new int[][](N^^2, 0);
    int[][] stepsByNode = new int[][](N^^2, 0);
    foreach(i, node, move; zip(iota(route.route.length.to!int), route.route, route.moves)) {
      movesByNode[node] ~= move;
      stepsByNode[node] ~= i;
    }

    foreach(dimension; [1]) {
      if (elapsed(1900)) continue BASE;
      int[] sequence;
      int[] nexts = (-1).repeat(route.route.length).array;

      int findReusable(int[] moves, int depth = 0) {
        NODE: foreach(start; 0..sequence.length.to!int) {
          auto cur = start;
          auto pre = -1;
          foreach(i, m; moves) {
            if (cur == -1) {
              continue NODE;
              // if (depth >= 0) continue NODE;
              // auto dig = findReusable(moves[i..$], depth + 1);
              // if (dig == -1) continue NODE;

              // deb([[[pre, nexts[pre], dig]]]);
              // nexts[pre] = dig;
              // return start; 
            }
            if (m != sequence[cur]) continue NODE;

            pre = cur;
            cur = nexts[cur];
          }
          return start;
        }
        return -1;
      }

      int[][] colors = new int[][](N^^2, 0);
      int currentColor = 0;
      foreach(node, moves; movesByNode.enumerate(0).array.sort!"a[1].length > b[1].length") {
        int pre = -1;
        foreach(i; 0..moves.length) {
          auto reuse = findReusable(moves[i..$]);

          if (reuse != -1) {
            if (pre == -1) {
              colors[node] ~= reuse;
            } else {
              nexts[pre] = reuse;
            }
            break;
          }

          auto color = currentColor;
          colors[node] ~= color;
          sequence ~= moves[i];
          if (pre != -1) {
            nexts[pre] = color;
          }
          pre = color;
          currentColor++;
        }

        if (pre != -1 && nexts[pre] == -1) {
          nexts[pre] = pre;
        }
      }

      if (currentColor + 4 < candidates[0].score || true) {
        string[] fns;
        foreach(color, move, nextColor; zip(iota(sequence.length), sequence, nexts)) {
          foreach(state; 0..4) {
            auto nextState = (state + move) % 4;
            fns ~= format("%s %s %s %s %s", color, state, max(0, nextColor), nextState, DIRS[nextState]);
          }
        }
        candidates ~= Ans(currentColor, 4, colors.map!(c => c.empty ? 0 : c[0]).array, fns);
        deb("score = ", currentColor + 4);
      }
    }
  }
  }
  
  candidates.map!"a.score".deb;
  candidates.minElement.outputAsAns();
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
