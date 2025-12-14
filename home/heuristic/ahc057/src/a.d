void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int T = scan!int;
  int M = scan!int;
  int K = scan!int;
  int L = scan!int;

  struct Node {
    float x, y, vx, vy;
  }

  auto nodes = iota(N).map!(_ => Node(scan!float, scan!float, scan!float, scan!float)).array;

  struct Operation {
    int t, i, j;
  }

  class Simulator {
    float[] x, y;
    float[] vx, vy;
    Operation[] ops;
    UnionFind uf;
    int currentTime;

    this() {
      x = nodes.map!"a.x".array;
      y = nodes.map!"a.y".array;
      vx = nodes.map!"a.vx".array;
      vy = nodes.map!"a.vy".array;

      uf = UnionFind(N);
      foreach(i; 0..N) {
        uf.setExtra(i, UnionFindExtra(1, nodes[i].vx, nodes[i].vy));
      }
    }

    bool mergable(int i, int j) {
      return true
        && (uf.size(i) + uf.size(j) <= K)
      ;
    }
    
    float calcMergeCost(int i, int j) {
      float[] ret;
      ret ~= (x[i] - x[j])^^2 + (y[i] - y[j])^^2;
      ret ~= (x[i] + L - x[j])^^2 + (y[i] - y[j])^^2;
      ret ~= (x[i] - x[j])^^2 + (y[i] + L - y[j])^^2;
      ret ~= (x[i] + L - x[j])^^2 + (y[i] + L - y[j])^^2;
      return ret.minElement;
    }

    void updateTime(int t) {
      int delta = t - currentTime;
      foreach(n; 0..N) {
        x[n] += vx[n] * delta + L;
        x[n] %= L;
        y[n] += vy[n] * delta + L;
        y[n] %= L;
      }
      currentTime = t;
    }

    void merge(int t, int i, int j) {
      updateTime(t);
      uf.unite(i, j);
      ops ~= Operation(t, i, j);
      foreach(n; 0..N) {
        vx[n] = uf.extra(n).vx;
        vy[n] = uf.extra(n).vy;
      }
    }

    void outputAsAns() {
      foreach(op; ops) {
        writefln("%s %s %s", op.t, op.i, op.j);
      }
    }
  }

  auto sim = new Simulator();
  auto solos = iota(M, N).redBlackTree;
  auto uniteds = iota(0, M).redBlackTree;
  int rest = N - M;

  foreach(t; 0..N - M) {
    int mergeTime = t * 3;
    sim.updateTime(mergeTime);

    int bestI, bestJ;
    float bestCost = float.max;
    foreach(i; uniteds.array) {
      if (rest == 0) break;

      foreach(j; solos.array) {
        if (rest == 0) break;
        if (!sim.mergable(i, j)) continue;

        auto cost = sim.calcMergeCost(i, j);

        if (cost <= 10000.0L) {
          sim.merge(mergeTime, i, j);
          rest--;
          solos.removeKey(j);
          uniteds.insert(j);
          cost.deb;
        }

        if (bestCost.chmin(cost)) {
          bestI = i;
          bestJ = j;
        }
      }
    }

    bestCost.deb;
    sim.merge(mergeTime, bestI, bestJ);
    solos.removeKey(bestJ);
    uniteds.insert(bestJ);
    rest--;
  }

  sim.outputAsAns();
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


struct UnionFindExtra {
  int size;
  float vx, vy;

  float momentX() { return vx * size; }
  float momentY() { return vy * size; }

  UnionFindExtra merge(UnionFindExtra other) {
    auto newSize = size + other.size;
    auto mx = momentX + other.momentX;
    auto my = momentY + other.momentY;
    return UnionFindExtra(newSize, mx / newSize, my / newSize);
  }
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

alias UnionFind = UnionFindWith!UnionFindExtra;
