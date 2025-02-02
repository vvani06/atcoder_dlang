void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int M = scan!int;
  int H = scan!int;
  int[] A = scan!int(N);
  int[][] E = scan!int(2 * M).chunks(2).array;
  int[][] XY = scan!int(2 * N).chunks(2).array;
  int[] idRandom = N.iota.array;
  
  struct Node {
    int id, value, depth, from = -1;

    inout int opCmp(inout Node other) {
      return cmp(
        [-value, idRandom[id]],
        [-other.value, idRandom[other.id]],
      );
    }
  }

  struct Sim {
    int score;
    int[] ans;
  }

  Sim simulate() {
    Node[] nodes = N.iota.map!(i => Node(i, A[i])).array;
    int[][] graph = new int[][](N, 0);
    foreach(e; E) {
      graph[e[0]] ~= e[1];
      graph[e[1]] ~= e[0];
    }

    int[] roots = (-1).repeat(N).array;
    bool[] used = new bool[](N);
    auto candidates = nodes.redBlackTree;
    int score;

    foreach(baseDepth; 0..H + 1) {
      int[] visits = new int[](N);
      int[][] visitsTo = new int[][](N, 0);

      foreach(node; candidates) {
        bool[] visited = used.dup;
        visited[node.id] = true;
        for(auto queue = DList!Node(Node(node.id, 0, baseDepth)); !queue.empty;) {
          auto cur = queue.front();
          queue.removeFront();
          visits[cur.id]++;
          visitsTo[node.id] ~= cur.id;
          if (cur.depth == H) continue;

          foreach(next; graph[cur.id]) {
            if (visited[next]) continue;

            visited[next] = true;
            queue.insertBack(Node(next, 0, cur.depth + 1));
          }
        }
      }

      int[] newRoots;
      foreach(node; candidates) {
        if (visitsTo[node.id].any!(n => visits[n] <= 1)) {
          used[node.id] = true;
          roots[node.id] = node.from;
          newRoots ~= node.id;
          score += node.value * (baseDepth + 1);
        } else {
          foreach(t; visitsTo[node.id]) visits[t]--;
        }
      }

      candidates.clear();
      foreach(nr; newRoots) {
        foreach(next; graph[nr]) {
          if (used[next]) continue;

          nodes[next].from = nr;
          candidates.insert(nodes[next]);
        }
      }
    }
    writefln("%(%s %)", roots);
    return Sim(score, roots);
  }

  auto sim = simulate();
  while(!elapsed(1850)) {
    idRandom.randomShuffle(RND);

    auto more = simulate();
    if (sim.score < more.score) {
      sim = more;
    }
  }

  writefln("%(%s %)", sim.ans);
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
