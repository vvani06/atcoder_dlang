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

  class Sim {
    RedBlackTree!int targets;
    RedBlackTree!int weapons;
    bool[] opened;
    int[] healthBoxes;
    int[] healthWeapons;
    BinaryHeap!(Edge[]) methods;
    Edge[] outputs;
    int calcedTurns;

    this() {
      targets = N.iota.redBlackTree;
      weapons = new int[](0).redBlackTree;
      opened = new bool[](N);
      healthBoxes = H.dup;
      healthWeapons = C.dup;
      methods = new Edge[](0).heapify;
    }

    Sim dup() {
      Sim ret = new Sim();
      ret.targets = targets.dup;
      ret.weapons = weapons.dup;
      ret.opened = opened.dup;
      ret.healthBoxes = healthBoxes.dup;
      ret.healthWeapons = healthWeapons.dup;
      ret.methods = methods.dup;
      ret.outputs = outputs.dup;
      ret.calcedTurns = calcedTurns;
      return ret;
    }

    long turns() {
      return opened.canFind(false) ? int.max : calcedTurns;
    }

    int[] assumeBestWeapon() {
      int[][] evals;
      foreach(w; targets) {
        if (opened[w]) continue;

        int score;
        int[] tmpHealthBoxes = healthBoxes.dup;
        foreach(_; 0..healthWeapons[w]) {
          int bestDelta, bestBox;
          foreach(t; targets) {
            if (t == w) continue;
            if (bestDelta.chmax(tmpHealthBoxes[t] - max(0, tmpHealthBoxes[t] - A[w][t]))) bestBox = t;
          }

          tmpHealthBoxes[bestBox] -= A[w][bestBox];
          tmpHealthBoxes[bestBox] = max(0, tmpHealthBoxes[bestBox]);
          score += bestDelta;
        }

        score *= 100_000;
        score /= healthBoxes[w];
        evals ~= [w, score];
      }

      evals.sort!"a[1] > b[1]";
      // evals[0..min(5, $)].deb;
      return evals.sort!"a[1] > b[1]".map!"a[0]".array;
    }

    void run(int maxPriority = 1) {
      while(opened.canFind(false)) {
        Edge method = {
          while(!methods.empty) {
            auto cur = methods.front;
            if (healthWeapons[cur.from] <= 0 || opened[cur.to]) {
              methods.removeFront();
              continue;
            }

            int realEffect = healthBoxes[cur.to] - max(0, healthBoxes[cur.to] - cur.value);
            if (realEffect != cur.value) {
              methods.removeFront();
              methods.insert(Edge(cur.from, cur.to, realEffect));
              continue;
            }

            return cur;
          }

          int target = {
            auto nextWeapons = assumeBestWeapon();
            return nextWeapons[0..min($, maxPriority)].choice(RND);
          }();
          return Edge(-1, target, 1);
        }();

        if (method.from >= 0) {
          if (--healthWeapons[method.from] <= 0) {
            weapons.removeKey(method.from);
          }
        } else {
          if (healthBoxes[method.to] > method.value) {
            outputs ~= Edge(method.from, method.to, healthBoxes[method.to] - method.value);
            calcedTurns += healthBoxes[method.to] - method.value;
            healthBoxes[method.to] = method.value;
          }
        }

        auto obtained = method.to;
        healthBoxes[obtained] -= method.value;
        if (healthBoxes[obtained] <= 0) {
          opened[obtained] = true;
          weapons.insert(obtained);
          targets.removeKey(obtained);
          foreach(to; 0..N) {
            if (!opened[to] && A[obtained][to] > 1) methods.insert(Edge(obtained, to, A[obtained][to]));
          }

          foreach(to; graph[obtained].map!"a.to") {
            if (--ins[to] == 0) {
              if (!opened[to]) targets.insert(to);
            }
          }
        }

        outputs ~= Edge(method.from, method.to, 1);
        calcedTurns++;
      }
    }

    void writeAns() {
      foreach(m; outputs) {
        foreach(_; 0..m.value) {
          writefln("%s %s", m.from, m.to);
        }
      }
    }
  }
  
  Sim bestSim = new Sim();
  bestSim.run(1);
  int prior = 3;
  while(!elapsed(1800)) {
    Sim sim = new Sim();
    sim.run(prior);
    if (bestSim.turns > sim.turns) {
      bestSim = sim;
    }
  }
  bestSim.writeAns();
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
