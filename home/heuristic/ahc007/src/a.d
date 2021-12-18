void main() { problem(); }

// ----------------------------------------------

void problem() {
  const long N = 400;
  const long M = 1995;
  auto P = N.iota.map!(_ => Point(scan!long, scan!long)).array;
  auto E = scan!long(2 * M).chunks(2).array;
  auto D = E.map!(e => distance(P[e[0]], P[e[1]])).array;
  auto LS = new long[](0);
  auto alternatives = new long[][](M, 0);

  bool[] createPredecisions() {
    alias Edge = Tuple!(long, "index", long, "value");
    auto edges = new Edge[][](N, 0);
    foreach(i, e; E) {
      edges[e[0]] ~= Edge(i, e[1]);
      edges[e[1]] ~= Edge(i, e[0]);
    }

    auto choice = new bool[](M);
    auto ds = D.enumerate.array;
    auto uf = UnionFind(N);
    foreach(l, e; zip(ds, E).array.sort!"a[0][1] < b[0][1]") {
      if (uf.same(e[0], e[1])) {
        continue;
      }

      uf.unite(e[0], e[1]);
      choice[l[0]] = true;

      long mi = int.max;
      long[] miSet;

      foreach(nex; edges[e[0]].filter!(a => a.index > l[0])) {
        foreach(nexx; edges[nex.value].filter!(a => a.index > l[0] && a.value == e[1])) {
          const dsum = D[nex.index] + D[nexx.index];
          if (dsum > 2.76 * l[1].to!real) continue;

          if (mi.chmin(dsum)) {
            miSet = [nex.index, nexx.index];
          }
        }
      }

      alternatives[l[0]] = miSet;
      // miSet.deb;
    }
    return choice;
  }

  auto solve() {
    auto choice = createPredecisions();
    auto rest = new long[](N);
    foreach(e; E) {
      rest[e[0]]++;
      rest[e[1]]++;
    }

    long total;
    auto uf = UnionFind(N);

    bool decide(long i, long[] e, long l) {
      if (uf.same(e[0], e[1])) return false;

      if (2.76 * D[i].to!real <= l && !(alternatives[i].empty)) {
        foreach(al; alternatives[i]) choice[al] = true;
        return false;
      }

      return choice[i];
    }

    foreach(i, e; E) {
      const l = scan!long;

      if (decide(i, e, l)) {
        uf.unite(e[0], e[1]);
        writeln(1);
        total += l;
      } else {
        writeln(0);
      }

      // rest[e[0]]--;
      // rest[e[1]]--;
      stdout.flush();
      LS ~= l;
    }

    // calc optimized

    debug {
      long opt;
      uf = UnionFind(N);
      auto edges = zip(LS, E).array;
      foreach(l, e; edges.sort!"a[0] < b[0]") {
        if (!uf.same(e[0], e[1])) {
          uf.unite(e[0], e[1]);
          opt += l;
        }
      }

      stderr.writeln("");
      stderr.writeln((10L^^8 * opt) / total);
    }
  }

  solve();
  exit(0);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
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
enum YESNO = [true: "Yes", false: "No"];

alias Point = Tuple!(long, "x", long, "y");
long distance(Point a, Point b) {
  return ((a.x - b.x)^^2 + (a.y - b.y)^^2).to!real.sqrt.to!long;
}

// -----------------------------------------------

struct UnionFind {
  long[] parent;

  this(long size) {
    parent.length = size;
    foreach(i; 0..size) parent[i] = i;
  }

  long root(long x) {
    if (parent[x] == x) return x;
    return parent[x] = root(parent[x]);
  }

  long unite(long x, long y) {
    long rootX = root(x);
    long rootY = root(y);

    if (rootX == rootY) return rootY;
    return parent[rootX] = rootY;
  }

  bool same(long x, long y) {
    long rootX = root(x);
    long rootY = root(y);

    return rootX == rootY;
  }
}
