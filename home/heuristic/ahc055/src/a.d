void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int[] H = scan!int(N);
  int[] C = scan!int(N);
  int[][] A = scan!int(N ^^ 2).chunks(N).array;

  struct Edge {
    int from, to, value;

    inout int opCmp(inout Edge other) {
      return cmp(
        [value, from, to],
        [other.value, other.from, other.to],
      );
    }
  }

  int[] ins = new int[](N);
  Edge[][] graph = new Edge[][](N, 0); {
    Edge[] edges;
    foreach(u; 0..N) foreach(v; 0..N) {
      if (u == v) continue;

      edges ~= Edge(u, v, A[u][v]);
    }

    auto uf = UnionFind(N);
    foreach(e; edges.sort!"a > b") {
      if (uf.same(e.from, e.to)) continue;

      uf.unite(e.from, e.to);
      graph[e.from] ~= e;
      ins[e.to]++;
    }
  }

  auto targets = (N.iota.filter!(i => ins[i] == 0).array).redBlackTree;
  targets = N.iota.redBlackTree;
  
  auto weapons = new int[](0).redBlackTree;
  bool[] opened = new bool[](N);

  auto healthBoxes = H.dup;
  auto healthWeapons = C.dup;
  auto methods = new Edge[](0).heapify;

  Edge[] outputs;

  int assumeBestWeapon() {
    int bestScore, bestWeapon;
    foreach(w; 0..N) {
      if (opened[w]) continue;

      int score;
      int[] tmpHealthBoxes = healthBoxes.dup;
      foreach(_; 0..healthWeapons[w]) {
        int bestDelta, bestBox;
        foreach(t; targets) {
          if (bestDelta.chmax(tmpHealthBoxes[t] - max(0, tmpHealthBoxes[t] - A[w][t]))) bestBox = t;
        }

        tmpHealthBoxes[bestBox] -= A[w][bestBox];
        tmpHealthBoxes[bestBox] = max(0, tmpHealthBoxes[bestBox]);
        score += bestDelta;
      }

      if (bestScore.chmax(score)) bestWeapon = w;
    }

    return bestWeapon;
  }

  int tries;
  while(opened.canFind(false)) {
    Edge method = {
      while(!methods.empty) {
        auto cur = methods.front;
        if (healthWeapons[cur.from] <= 0 || opened[cur.to]) {
          methods.removeFront();
          continue;
        }

        return cur;
      }

      // int mini = int.max;
      // int target;
      // foreach(t; targets) {
      //   if (mini.chmin(healthBoxes[t])) target = t;
      // }

      int target = assumeBestWeapon();
      return Edge(-1, target, 1);
    }();

    if (method.from >= 0) {
      if (--healthWeapons[method.from]) {
      }
    } else {
      while(healthBoxes[method.to] > method.value) {
        healthBoxes[method.to] -= method.value;
        outputs ~= method;
      }
    }

    auto obtained = method.to;
    healthBoxes[obtained] -= method.value;
    if (healthBoxes[obtained] <= 0) {
      targets.removeKey(obtained);
      opened[obtained] = true;
      foreach(to; 0..N) {
        if (!opened[to]) methods.insert(Edge(obtained, to, A[obtained][to]));
      }

      foreach(to; graph[obtained].map!"a.to") {
        if (--ins[to] == 0) {
          if (!opened[to]) targets.insert(to);
        }
      }
    }

    outputs ~= method;
  }

  foreach(m; outputs) writefln("%s %s", m.from, m.to);
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
 
    if (sizes[rootX] < sizes[rootY]) {
      swap(x, y);
      swap(rootX, rootY);
      w *= -1;
    }

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
