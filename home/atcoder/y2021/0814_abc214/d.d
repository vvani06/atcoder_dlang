void main() { runSolver(); }

void problem() {
  auto N = scan!long;
  auto P = scan!long(3 * N - 3).chunks(3).array;

  auto solve() {
    alias Path = Tuple!(long, "from", long, "to", long, "cost");
    auto pathesAll = new Path[](0);
    Path[][] pathes;
    pathes.length = N;
    foreach(p; P) {
      p[0]--; p[1]--;
      pathes[p[0]] ~= Path(p[0], p[1], p[2]);
      pathes[p[1]] ~= Path(p[1], p[0], p[2]);
      pathesAll ~= Path(p[0], p[1], p[2]);
    }

    auto uf = UnionFind(N);
    long ans;
    foreach(p; pathesAll.sort!"a.cost < b.cost") {
      long m;
      foreach(node; [p.from, p.to]) foreach(n; pathes[node]) {
        if (uf.same(n.from, n.to)) continue;

        if (n.cost <= p.cost) {
          m += uf.size(n.to);
          uf.unite(n.from, n.to);
          "unite".deb;
        }
      }
      deb(p, m);
      ans += p.cost * m;
    }

    return ans;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop;
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
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
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(true) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct UnionFind {
  long[] parent;
  long[] sizes;

  this(long size) {
    parent.length = size;
    foreach(i; 0..size) parent[i] = i;

    sizes.length = size;
    sizes[] = 1;
  }

  long root(long x) {
    if (parent[x] == x) return x;
    return parent[x] = root(parent[x]);
  }

  long unite(long x, long y) {
    long rootX = root(x);
    long rootY = root(y);
    if (rootX == rootY) return rootY;

    sizes[rootY] += sizes[rootX];
    return parent[rootX] = rootY;
  }

  bool same(long x, long y) {
    long rootX = root(x);
    long rootY = root(y);

    return rootX == rootY;
  }

  long size(long x) {
    return sizes[root(x)];
  }
}
