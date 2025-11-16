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
    enum int moveCost = 10;
    int[][] dirs;
    int[][] distances;
    int[] visitCount;

    int[] route;
    int[] moves;
    int visitedCost;

    // int calcId;
    // int[400][4] calced;
    // Queue[400][4] froms;
    // int[400][4] costs;

    this(int visitedCost) {
      dirs = new int[][](N^^2, N^^2);
      distances = new int[][](N^^2, N^^2);
      visitCount = new int[](N^^2);
      this.visitedCost = visitedCost;
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

        foreach(dd; 0..2) {
          auto turned = (cur.dir + dd) % 4;
          auto to = cur.node + (walkable[cur.node][turned] ? DELTA[turned] : 0);

          auto cost = cur.cost + moveCost + visitCount[to]*visitedCost;
          if (costs[to][turned].chmin(cost)) {
            froms[to][turned] = cur;
            queue.insert(Queue(to, turned, cost));
          }
        }
      }

      auto node = goal;
      auto dir = queue.front.dir;
      DList!int backtrack;
      DList!int backtrackMove;
      while (!(node == start && dir == startDir)) {
        visitCount[node]++;
        backtrack.insertFront(node);
        backtrackMove.insertFront(dir == froms[node][dir].dir ? 0 : 1);

        auto nn = froms[node][dir].node;
        dir = froms[node][dir].dir;
        node = nn;
      }
      backtrack.insertFront(node);
      backtrackMove.insertFront(dir == froms[node][dir].dir ? 0 : 1);

      route ~= backtrack.array[0..$ - 1];
      moves ~= backtrackMove.array[1..$];
      return queue.front.dir;
    }
  }

  auto route = Route(10);

  int currentDir;
  foreach(i; 0..K - 1) {
    currentDir = route.walk(XYI[i], currentDir, XYI[i + 1]);
  }
  route.route.deb;

  int[][] movesByNode = new int[][](N^^2, 0);
  int[][] stepsByNode = new int[][](N^^2, 0);
  foreach(i, node, move; zip(iota(route.route.length.to!int), route.route, route.moves)) {
    movesByNode[node] ~= move;
    stepsByNode[node] ~= i;
  }
  // movesByNode.each!deb;
  int[] sequence;
  int[] nexts = (-1).repeat(route.route.length).array;

  int findReusable(int[] moves) {
    NODE: foreach(start; 0..sequence.length.to!int) {
      auto cur = start;
      foreach(m; moves) {
        if (cur == -1 || m != sequence[cur]) continue NODE;

        cur = nexts[cur];
      }
      return start;
    }
    return -1;
  }

  int[][] colors = new int[][](N^^2, 0);
  int currentColor;
  foreach(node, moves; movesByNode.enumerate(0).array.sort!"a[1].length > b[1].length") {
    if (node == 190) moves.deb;

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
  }

  {
    int seq = colors[190][0];
    foreach(_; 0..10) {
      if (seq == -1) break;
      deb([seq, sequence[seq]]);
      seq = nexts[seq];
    }
  }

  writefln("%s %s %s", currentColor, 4, currentColor * 4);
  foreach(col; colors.map!(c => c.empty ? 0 : c[0]).chunks(N)) writefln("%(%s %)", col);
  foreach(color, move, nextColor; zip(iota(sequence.length), sequence, nexts)) {
    foreach(state; 0..4) {
      auto nextState = (state + move) % 4;
      writefln("%s %s %s %s %s", color, state, max(0, nextColor), nextState, DIRS[nextState]);
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

struct UnionFindWith(T = UnionFindExtra) {
  int[] roots;
  int[] sizes;
  long[] weights;
  T[] extras;
 
  this(int size) {
    roots = size.iota.array;
    sizes = 1.repeat(size).array;
    weights = 0L.repeat(size).array;
    extras = new T[](size);
  }
 
  this(int size, T[] ex) {
    roots = size.iota.array;
    sizes = 1.repeat(size).array;
    weights = 0L.repeat(size).array;
    extras = ex.dup;
  }
 
  int root(int x) {
    if (roots[x] == x) return x;

    const root = root(roots[x]);
    weights[x] += weights[roots[x]];
    return roots[x] = root;
  }

  int size(int x) {
    return sizes[root(x)];
  }

  T extra(int x) {
    return extras[root(x)];
  }

  T setExtra(int x, T t) {
    return extras[root(x)] = t;
  }
 
  bool unite(int x, int y, long w = 0) {
    int rootX = root(x);
    int rootY = root(y);
    if (rootX == rootY) return weights[x] - weights[y] == w;
 
    // if (rootX < rootY) {
    //   swap(x, y);
    //   swap(rootX, rootY);
    //   w *= -1;
    // }

    sizes[rootX] += sizes[rootY];
    weights[rootY] = weights[x] - weights[y] - w;
    extras[rootX] = extras[rootX].merge(extras[rootY]);
    roots[rootY] = rootX;
    return true;
  }
 
  bool same(int x, int y, int w = 0) {
    int rootX = root(x);
    int rootY = root(y);
 
    return rootX == rootY && weights[rootX] - weights[rootY] == w;
  }

  auto dup() {
    auto dupe = UnionFindWith!T(roots.length.to!int);
    dupe.roots = roots.dup;
    dupe.sizes = sizes.dup;
    dupe.weights = weights.dup;
    dupe.extras = extras.dup;
    return dupe;
  }
}

struct UnionFindExtra { UnionFindExtra merge(UnionFindExtra other) { return UnionFindExtra(); } }
alias UnionFind = UnionFindWith!UnionFindExtra;
