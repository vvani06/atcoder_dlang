void main() { runSolver(); }

// ----------------------------------------------

enum long INF = 10 ^^ 9;

struct Edge {
  int id, u, v; long w;

  inout int opCmp(Edge other) {
    if (w < other.w) return 1;
    if (w > other.w) return -1;
    if (id < other.id) return 1;
    if (id > other.id) return -1;
    return 0;
  }
}

struct Evaluation {
  City city;
  int start;
  int[] from;
  long[] costs;
  bool[] disabled;

  this(City city, int start) {
    this.city = city;
    this.start = start;
    disabled = new bool[](city.M);
    
    auto c = computeDistances();
    costs = c[0];
    from = c[1];
  }

  Tuple!(long[], int[]) computeDistances() {
    auto ret = new long[](city.N);
    ret[] = 10 ^^ 9;
    ret[start] = 0;

    auto from = new int[](city.N);
    from[] = -1;

    alias Exam = Tuple!(int, "node", long, "cost");
    for(auto queue = [Exam(start, 0)].heapify!"a.cost > b.cost"; !queue.empty;) {
      auto p = queue.front; queue.removeFront;
      if (ret[p.node] != p.cost) continue;
      
      foreach(e; city.graph[p.node]) {
        if (disabled[e.id]) continue;

        const d = p.cost + e.w;
        if (ret[e.v].chmin(d)) {
          from[e.v] = e.id;
          queue.insert(Exam(e.v, d));
        }
      }
    }

    return tuple(ret, from);
  }

  long setDisabled(int edgeId) {
    auto edge = city.E[edgeId];

    

    return 0;
  }
}

struct City {
  int N, M;
  Edge[] E;
  Edge[][] graph;

  long[][] dist0;

  this(int N, int M, Edge[] E) {
    this.N = N;
    this.M = M;
    this.E = E;
    graph = new Edge[][](N, 0);
    foreach(e; E) {
      graph[e.u] ~= Edge(e.id, e.u, e.v, e.w);
      graph[e.v] ~= Edge(e.id, e.v, e.u, e.w);
    }
  }
}

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto D = scan!int;
  auto K = scan!int;
  auto E = M.iota.map!(i => Edge(i, scan!int - 1, scan!int - 1, scan!long)).array;
  auto P = scan!long(2 * N).chunks(2).array;
  
  auto solve() {
    auto city = City(N, M, E);

    auto evaluation = Evaluation(city, 0);
    evaluation.from.deb;

    const limit = min(K, (M + D - 1) / D);
    int[][] schedule;
    auto finished = new bool[](M);
    auto et = city.E.redBlackTree; // E.filter!(e => must[e.id] == inMst).redBlackTree;
    while(!et.empty) {
      int[] targets;
      auto available = city.graph.map!"a.length.to!int".array;
      auto used = new int[](N);

      void construct(Edge e) {
        et.removeKey(e);
        targets ~= e.id;
        finished[e.id] = true;
        available[e.u]--;
        available[e.v]--;
        used[e.u]++;
        used[e.v]++;
      }

      while(targets.length < limit) {
        auto cur = et.front;
        int curBest = int.max;
        foreach(e; et.array) {
          if (curBest.chmin(used[e.u] + used[e.v])) cur = e;
        }
        while(targets.length < limit) {
          construct(cur);

          int best = int.max;
          Edge bestEdge = cur;
          foreach(next; city.graph[cur.v]) {
            if (finished[next.id]) continue;
            if (used[next.v] > 0) continue;
            
            bestEdge = next;
            break;
          }
          cur = bestEdge;
          if (finished[cur.id]) break;
        }
      }
      schedule ~= targets;
    }

    auto ans = new int[](M);
    auto perDay = min(K, (M + D - 1) / D);
    int day = 1, count = 0;

    schedule.map!"a.length".deb;
    perDay = min(K, (schedule.map!"a.length".sum + D - 1) / D);
    foreach(s; schedule) {
      foreach(r; s) {
        ans[r] = day;
        if (++count == perDay) {
          day++; count = 0;
        }
      }
      // day++; count = 0;
    }

    // iota(1, D+1).map!(d => ans.count(d)).deb;
    // schedule.map!"a.length".deb;
    ans.toAnswerString.writeln;
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
