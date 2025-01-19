void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int M = scan!int;
  int H = scan!int;
  int[] A = scan!int(N);
  int[][] E = scan!int(2 * M).chunks(2).array;
  int[][] XY = scan!int(2 * N).chunks(2).array;
  
  struct Node {
    int node, value;
  }

  auto nodes = N.iota.map!(i => Node(i, A[i])).array.sort!"a.value > b.value";
  int[][] graph = new int[][](N, 0);
  foreach(e; E) {
    graph[e[0]] ~= e[1];
    graph[e[1]] ~= e[0];
  }

  Tuple!(int, int[]) solve(int tried) {
    if (tried == 0) {
      foreach(ref g; graph) g.sort!((a, b) => A[a] < A[b]);
    } else {
      foreach(ref g; graph) g.randomShuffle(RND);
    }

    bool[] used = new bool[](N);
    int[] roots = (-1).repeat(N).array;
    int[] rootIds;

    alias Item = Tuple!(int, "node", int, "depth");
    auto heap = new Item[](0).heapify!"a.depth < b.depth";

    auto availables = N.iota.map!(i => graph[i].redBlackTree).array;

    foreach(leaf; nodes) {
      if (used[leaf.node]) continue;

      used[leaf.node] = true;
      int[] route;

      int dfs(int cur, int pre, int depth) {
        if (depth > H) return depth;

        foreach(next; graph[cur]) {
          if (next == pre || used[next]) continue;

          roots[cur] = next;
          used[next] = true;
          route ~= next;
          return dfs(next, cur, depth + 1);
        }
        return depth;
      }

      int maxDepth = dfs(leaf.node, leaf.node, 1);
      foreach(depth, node; route.retro.enumerate(1)) heap.insert(Item(node, depth));

      while(!heap.empty) {
        Item item = heap.front;
        heap.removeFront;

        auto branch = item.node;
        foreach(next; availables[branch].array) {
          availables[branch].removeKey(next);
          if (used[next]) continue;

          roots[next] = branch;
          used[next] = true;
          if (item.depth < H) heap.insert(Item(next, item.depth + 1));
          if (!availables[branch].empty) {
            heap.insert(item);
            break;
          }
        }
      }

      rootIds ~= route.empty ? leaf.node : route[$ - 1];
    }

    int[][] trees = new int[][](N, 0);
    foreach(cur, root; roots.enumerate(0)) {
      if (root != -1) trees[root] ~= cur;
    }

    int heightSum;
    int score = 1;
    foreach(root; rootIds) {
      void countHeights(int cur, int depth) {
        heightSum += depth;
        score += depth * A[cur];
        foreach(next; trees[cur]) countHeights(next, depth + 1);
      }
      countHeights(root, 1);
    }
    (heightSum.to!real / N).deb;
    score.deb;
    // writefln("%(%s %)", roots);

    return tuple(score, roots);
  }

  int[] ans;
  int bestScore;
  int tried;
  while(!elapsed(1800)) {
    auto ret = solve(tried++);
    if (bestScore.chmax(ret[0])) ans = ret[1];
    break;
  }
  writefln("%(%s %)", ans);
}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("# "); writeln(t); }}
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

struct UnionFind {
  int[] roots;
  int[] sizes;
  long[] weights;
 
  this(int size) {
    roots = size.iota.array;
    sizes = 1.repeat(size).array;
    weights = 0L.repeat(size).array;
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
 
  bool unite(int x, int y, long w = 0) {
    int rootX = root(x);
    int rootY = root(y);
    if (rootX == rootY) return weights[x] - weights[y] == w;
 
    if (sizes[rootX] < sizes[rootY]) {
      swap(x, y);
      swap(rootX, rootY);
      w *= -1;
    }

    sizes[rootX] += sizes[rootY];
    weights[rootY] = weights[x] - weights[y] - w;
    roots[rootY] = rootX;
    return true;
  }
 
  bool same(int x, int y, int w = 0) {
    int rootX = root(x);
    int rootY = root(y);
 
    return rootX == rootY && weights[rootX] - weights[rootY] == w;
  }
}
