void main() { runSolver(); }

// ----------------------------------------------

void problem() {
  auto M = scan!int;
  auto E = scan!real;
  auto RANDOM = Xorshift(unpredictableSeed);

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
      this(triangle(size).iota.map!(_ => cast(dchar)('0' + uniform(0, 2, RANDOM))).to!string);
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

    Graph simulate(real r) {
      string s;
      foreach(c; sourceString) {
        auto rand = uniform(0.0f, 1.0f, RANDOM);
        if (rand < r) {
          s ~= c == '0' ? '1' : '0';
        } else {
          s ~= c;
        }
      }
      return Graph(s);
    }

    real distance(Graph other) {
      real ret = 0;
      foreach(a, b; zip(degrees, other.degrees)) {
        ret += pow(3.1415, (a - b).abs);
      }

      return ret;
    }

    string toString() {
      return sourceString;
    }
  }

  auto createSmallGraphs(int graphSize) {
    Graph[] graphs;
    graphs ~= Graph('0'.repeat(Graph.triangle(graphSize)).to!string);
    graphs ~= Graph('1'.repeat(Graph.triangle(graphSize)).to!string);
    foreach(_; 2..M) {
      Graph best;
      real bestScore = 0;
      foreach(t; 0..6000/graphSize) {
        auto c = Graph(graphSize);
        auto minDistance = graphs.map!(g => g.distance(c)).minElement;
        if (bestScore.chmax(minDistance)) best = c;
      }
      if (bestScore == 0) break;
      graphs ~= best;
    }

    return graphs;
  }

  auto createLargeGraphs(int graphSize) {
    const edgeSize = Graph.triangle(graphSize);
    const edgeStep = edgeSize / (M - 1);

    Graph[] graphs;
    bool[int] edges;
    bool[int[]] used;
    foreach(i; 0..edgeSize) edges[i] = true;
    char[] workGraph = new char[](edgeSize); workGraph[] = '0';
    graphs ~= Graph(workGraph.to!string);
    used[graphs[$ - 1].degrees.idup] = true;
    while(graphs.length < M) {
      auto shuffled = edges.keys.randomShuffle(RANDOM)[0..edgeStep];
      auto wg = workGraph.dup;
      foreach(e; shuffled) wg[e] = '1';
      auto g = Graph(wg.to!string);
      
      if (g.degrees in used) continue;

      graphs ~= g;
      workGraph = wg;
      foreach(e; shuffled) edges.remove(e);
    }

    return graphs;
  }
  
  auto solve() {
    int graphSize;
    if (M <= 11) graphSize = 4;
    else if (M <= 31) graphSize = 5;
    else graphSize = 6;
    graphSize *= (1.00 + E*75);
    graphSize = min(100, graphSize);
    if (graphSize > 16 && graphSize < 33) graphSize = 15;

    auto graphs = graphSize < 16 ? createSmallGraphs(graphSize) : createLargeGraphs(graphSize);
    graphSize.writeln();
    graphs.each!writeln();
    stdout.flush();

    foreach(k; 0..100) {
      auto graph = Graph(scan);

      auto distances = new real[](M);
      distances[] = 0.0;
      foreach(t; 0..14000/M/graphSize) {
        long ans;
        real bestScore = real.max;
        foreach(i, g; graphs) {
          const d = graph.distance(g.simulate(E));
          distances[i] += d;
        }
      }

      // samples.maxIndex.writeln;
      distances.minIndex.writeln;
      stdout.flush();
    }
  }

  solve();
}

// ----------------------------------------------

import std;
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
  debug { BORDER.writeln; { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
