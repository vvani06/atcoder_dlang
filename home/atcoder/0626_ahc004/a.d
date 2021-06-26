void main() { runSolver(); }

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto S = scan!string(M);

  auto solve() {
    auto ans = new char[][](N, N);
    foreach(ref s; ans) s[] = '.';

    long[string] score;
    foreach(s; S) score[s] = 0;

    auto extracted = new string[](0);
    foreach(s; S.sort!"a.length > b.length") {
      foreach(e; extracted) {
        bool found;
        
        if (e.canFind(s)) {
          score[e]++;
          found = true;
        }

        if (found) continue;
      }

      extracted ~= s;
    }

    long x, y;

    bool[string] used;
    auto sorted = extracted.sort!((a, b) => score[a] > score[b]).array;
    foreach(i, s; sorted) {
      if (s in used) continue;

      const l = s.length;
      if (x + l > N) {
        foreach(ss; sorted[i+1..$]) {
          if (!(ss in used) && x + ss.length <= N) {
            ans[y][x..x + ss.length] = ss;
            x += ss.length;
            used[ss] = true;
          }
        }
        x = 0;
        y++;
      }

      if (y >= N) break;

      ans[y][x..x + l] = s;
      x += l;
      used[s] = true;
    }

    ans.each!writeln;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import core.checkedint;
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
