void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);

  int N = scan!int;
  long[][] AB = scan!long(2 * N).chunks(2).array;

  struct Soda {
    long a, b;

    long smaller() {
      return min(a, b);
    }

    long sum() {
      return a + b;
    }

    Soda viaPoint(Soda other) {
      return Soda(
        min(a, other.a),
        min(b, other.b),
      );
    }

    long dist(ref Soda other) {
      if (other.a < a || other.b < b) return long.max;

      return other.a - a + other.b - b;
    }

    inout opCmp(ref Soda other) {
      return cmp(
        [a, b],
        [other.a, other.b]
      );
    }
  }

  struct Eval {
    int node;
    long cost;

    inout opCmp(inout const Eval other) {
      return cmp(
        [cost, node],
        [other.cost, other.node],
      );
    }
  }

  Soda[] requirements = AB.map!(ab => Soda(ab[0], ab[1])).array;
  Soda[] nodes = [Soda(0, 0)] ~ requirements.sort!"a.sum < b.sum".array;
  int[Soda] nodeIndexPerSoda = [Soda(0, 0): 0];
  int[][] graph = new int[][](N ^^ 2, 0);
  long[] costs = new long[](N ^^ 2);
  auto evaluates = new Eval[](0).redBlackTree;
  
  foreach(to, req; nodes[1..$].enumerate(1)) {
    long distBest = long.max;
    int fromBest;
    foreach(i, from; nodes) {
      if (to == i) continue;
      if (distBest.chmin(from.dist(req))) fromBest = i.to!int;
    }
    
    graph[fromBest] ~= to;
    nodeIndexPerSoda[req] = to;
    auto eval = Eval(fromBest, costs[fromBest]);
    evaluates.removeKey(eval);
    costs[fromBest] += distBest;
    eval.cost += distBest;
    evaluates.insert(eval);
  }

  long calcCost(int from, int to) {
    return min(
      nodes[from].dist(nodes[to]),
      nodes[to].dist(nodes[from]),
    );
  }

  int newNodeIndex = N + 1;
  foreach(_; 0..4 * N) {
    if (evaluates.empty) break;
    auto worst = evaluates.back;
    evaluates.removeBack;
    auto from = worst.node;
    auto nextSize = graph[from].length.to!int;

    long bestImprove = 0;
    int[] bestPair;
    foreach(i; 0..nextSize - 1) {
      auto destA = graph[from][i];
      long baseCost = calcCost(from, destA);
      foreach(j; i + 1..nextSize) {
        auto destB = graph[from][j];
        long cost = baseCost + calcCost(from, destB);

        auto via = nodes[destA].viaPoint(nodes[destB]);
        long viaCost = via.dist(nodes[destA]) + via.dist(nodes[destB]) + nodes[from].dist(via);
        long improve = cost - viaCost;

        if (bestImprove.chmax(improve)) {
          bestPair = [i, j];
        }
      }
    }

    if (bestPair.empty) continue;

    // deb(bestImprove, bestPair);
    worst.cost -= bestImprove;
    evaluates.insert(worst);
    auto destA = graph[from][bestPair[0]];
    auto destB = graph[from][bestPair[1]];
    graph[from] = graph[from][0..bestPair[1]] ~ graph[from][bestPair[1] + 1..$];
    graph[from] = graph[from][0..bestPair[0]] ~ graph[from][bestPair[0] + 1..$];

    auto via = nodes[destA].viaPoint(nodes[destB]);
    int newIndex;
    if (via in nodeIndexPerSoda) {
      newIndex = nodeIndexPerSoda[via];
    } else {
      newIndex = newNodeIndex++;
    }
    if (!graph[from].canFind(newIndex)) graph[from] ~= newIndex;
    graph[newIndex] ~= [destA, destB];
    nodes ~= via;
  }

  { // output --------------------------------------------------------
    struct CreateSoda {
      Soda from;
      Soda to;

      string toOutput() {
        return "%s %s %s %s".format(from.a, from.b, to.a, to.b);
      }
    }

    CreateSoda[] ans;
    for(auto queue = DList!int(0); !queue.empty;) {
      auto cur = queue.front;
      queue.removeFront;

      foreach(next; graph[cur]) {
        ans ~= CreateSoda(nodes[cur], nodes[next]);
        queue.insertBack(next);
      }
    }

    writeln(ans.length);
    foreach(a; ans) writeln(a.toOutput());
  }

}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("# "); writeln(t); }}
// void deb(T ...)(T t){ debug {  }}
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
  problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

