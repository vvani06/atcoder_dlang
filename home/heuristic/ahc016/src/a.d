void main() { runSolver(); }

// ----------------------------------------------

void problem() {
  auto M = scan!int;
  auto E = scan!real;

  struct Graph {
    string sourceString;
    int size;
    bool[] edges;
    int[] dg;

    static int triangle(int k) { return k * (k - 1) / 2; }

    this(string s) {
      sourceString = s;
      edges = s.map!(c => c == '1').array;
      const l = s.length;
      foreach(i; 4..101) {
        if (triangle(i) == l) {
          size = i;
          break;
        }
      }
    }

    this(int size) {
      this(triangle(size).iota.map!(_ => cast(dchar)('0' + uniform(0, 2))).to!string);
    }

    int[] degrees() {
      if (!dg.empty) return dg;

      auto ret = new int[](size);
      const base = triangle(size);
      foreach(i; 0..size - 1) {
        const offset = base - triangle(size - i);
        foreach(j; i + 1..size) {
          if (edges[offset + j - i - 1]) {
            ret[i]++;
            ret[j]++;
          }
        }
      }

      ret.sort;
      return dg = ret;
    }

    long distance(Graph other) {
      long ret;
      foreach(a, b; zip(degrees, other.degrees)) {
        ret += (a - b) ^^ 2;
      }

      return ret;
    }

    string toString() {
      return sourceString;
    }
  }
  
  auto solve() {
    int graphSize = 20.iota.countUntil!(i => i * (i + 1) / 2 >= M).to!int;
    auto er = max(1.0, (E / 0.4) * 4);
    Graph[] graphs;
    graphs ~= Graph('0'.repeat(Graph.triangle(graphSize)).to!string);
    graphs ~= Graph('1'.repeat(Graph.triangle(graphSize)).to!string);
    foreach(_; 2..M) {
      Graph best;
      long bestScore = -1;
      foreach(t; 0..400) {
        auto c = Graph(graphSize);
        auto minDistance = graphs.map!(g => g.distance(c)).minElement;
        if (bestScore.chmax(minDistance)) best = c;
      }
      graphs ~= best;
      bestScore.deb;
    }

    graphSize.writeln();
    graphs.each!writeln();
    stdout.flush();

    foreach(k; 0..100) {
      auto graph = Graph(scan);

      long ans;
      long bestScore = long.max;
      foreach(i, g; graphs) {
        const d = graph.distance(g);
        if (bestScore.chmin(d)) ans = i;
      }

      ans.writeln;
      stdout.flush();
    }
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
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
