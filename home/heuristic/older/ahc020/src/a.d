void main() { runSolver(); }

// ----------------------------------------------

struct Coord {
  int x, y;

  int norm() {
    return x*x + y*y;
  }

  Coord sub(Coord other) {
    return Coord(x - other.x, y - other.y);
  }
}

struct Edge {
  int id, from, to, cost;
}

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto K = scan!int;
  auto P = N.iota.map!(_ => Coord(scan!int, scan!int)).array;
  auto E = M.iota.map!(id => Edge(id, scan!int - 1, scan!int - 1, scan!int)).array;
  auto A = K.iota.map!(_ => Coord(scan!int, scan!int)).array;
  auto RND = Xorshift(unpredictableSeed);

  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

  auto solve() {
    auto covered = new bool[](K);
    auto powers = new int[](N);

    enum NORM_MAX = 5000^^2;
    foreach(a; 0..K) {
      if (covered[a]) continue;
      int minNorm = int.max;
      int minNode;

      foreach(p; 0..N) {
        const norm = A[a].sub(P[p]).norm;
        if (norm > NORM_MAX) continue;

        if (minNorm.chmin(norm)) {
          minNode = p;
        }
      }

      auto base = P[minNode];
      foreach(b; 0..K) {
        if (base.sub(A[b]).norm <= minNorm) {
          covered[b] = true;
        }
      }

      auto dist = minNorm.to!real.sqrt.to!int;
      powers[minNode].chmax(dist);
    }

    auto connections = new int[](M);
    auto uf = UnionFind(N);
    foreach(e; E.sort!"a.cost < b.cost") {
      if (uf.same(e.from, e.to)) continue;

      uf.unite(e.from, e.to);
      connections[e.id] = 1;
    }

    powers.toAnswerString.writeln;
    connections.toAnswerString.writeln;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
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
  enum BORDER = "#==================================";
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; break; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct UnionFind {
  int[] parent;
  int[] sizes;
 
  this(int size) {
    parent = size.iota.array;
    sizes = 1.repeat(size).array;
  }
 
  int root(int x) {
    if (parent[x] == x) return x;
    return parent[x] = root(parent[x]);
  }

  int size(int x) {
    return sizes[root(x)];
  }
 
  int unite(int x, int y) {
    int rootX = root(x);
    int rootY = root(y);
 
    if (rootX == rootY) return rootY;
 
    if (sizes[rootX] < sizes[rootY]) {
      sizes[rootY] += sizes[rootX];
      return parent[rootX] = rootY;
    } else {
      sizes[rootX] += sizes[rootY];
      return parent[rootY] = rootX;
    }
  }
 
  bool same(int x, int y) {
    int rootX = root(x);
    int rootY = root(y);
 
    return rootX == rootY;
  }
}
