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
          ret[cur].dirStates ~= DirState(dirStr(dir)[0], step);
          cur += [-1, -N, 1, N][dir];
          step++;
        }
      }
      return ret;
    }
  }

  auto route = Route(false.repeat(N^^2).array);
  auto dirStatesPerNode = route.dirStatesPerNode();
  // dirStatesPerNode.each!deb;
  
  alias Next = Tuple!(int, "color", int, "state", dchar, "dir");
  alias Key = Tuple!(int, "color", int, "state");
  Next[Key] bestFn;
  int[] bestColors;
  int bestColorSize, bestStateSize;
  int best = int.max;
  
  foreach(stateSize; 1..route.length.to!real.sqrt.to!int * 2) {
    int[] nextColorByState = new int[](stateSize);
    int[][] colorByNode = new int[][](N^^2, 0);
    Next[Key] fn;

    DirState[] sequence;
    int[] graph = new int[](route.length);
    int[] graphColor = new int[](route.length);
    int[][] revGraph = new int[][](route.length, 0);
    int[][DirState] dsSeqs;

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
        if (sequence[next] == dss[step] && dfs(graph[cur], step + 1)) return true;
        return false;
      }

      foreach(from; dsSeqs[dss.front]) {
        if (dfs(from, 1)) return from;
      }
      return -1;
    }

    foreach(dsn; dirStatesPerNode) {
      auto node = dsn.node;
      auto preKey = Key(-1, -1);
      int preIndex;
      auto dirStates = dsn.dirStates.map!(ds => DirState(ds.dir, ds.state % stateSize)).array;
      // dirStates.deb;
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
