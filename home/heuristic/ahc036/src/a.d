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
  int M = scan!int;
  int TN = scan!int;
  int LA = scan!int;
  int LB = scan!int;
  int[][] UV = scan!int(2 * M).chunks(2).array;
  int[] T = scan!int(TN);
  int[][] XY = scan!int(2 * N).chunks(2).array;

  struct HashValue {
    int count, length, index;
    long hash;

    const int opCmp(const HashValue other) {
      return cmp(
        [count * length, length, hash],
        [other.count * other.length, other.length, other.hash],
      );
    }
  }

  struct Ans {
    int score;
    string output;

    const int opCmp(const Ans other) {
      return cmp(
        [score, ],
        [other.score, ]
      );
    }
  }

  final class Simulator {
    int[][] graph;

    int[] route;

    this(int[][] g) {
      graph = g.map!"a.dup".array;

      provisionRoute();
      provisionSignal();
    }

    int[][] nexts;
    void provisionRoute() {
      nexts = new int[][](N, N);

      // 900ms per run
      foreach(to; 0..N) {
        int[] froms = new int[](N);
        froms[] = -1;
        froms[to] = to;
        for(auto queue = DList!int(to); !queue.empty;) {
          auto cur = queue.front;
          queue.removeFront;

          foreach(next; graph[cur]) {
            if (froms[next] != -1) continue;

            queue.insertBack(next);
            froms[next] = cur;
          }
          foreach(from; 0..N) {
            nexts[from][to] = froms[from];
          }
        }
      }

      int cur = 0;
      foreach(t; T) {
        while(cur != t) {
          cur = nexts[cur][t];
          route ~= cur;
        }
      }
    }

    int[] signals;
    int[long][] indiciesForSignalHash;
    int[] indiciesForSignal;

    // 400ms per run
    void provisionSignal() {
      indiciesForSignalHash = new int[long][](LB + 1);
      indiciesForSignal = new int[](N);

      long[][] hashes = new long[][](LB + 1, route.length);
      int[long][] hashCount = new int[long][](LB + 1);
      int[long][] hashIndex = new int[long][](LB + 1);
      auto hashTree = new HashValue[](0).redBlackTree!"a > b";
      
      foreach(l; 1..LB + 1) {
        foreach(i; 0..route.length) {
          auto uniqueNodes = route[i..min($, i + l)].dup.sort.uniq;
          long hash;
          foreach(n; uniqueNodes) hash ^= n.hashOf(seed);
          hashes[l][i] = hash;
          hashCount[l][hash]++;
          hashIndex[l].require(hash, i.to!int);
        }
        
        foreach(hash; hashCount[l].keys) {
          hashTree.insert(HashValue(hashCount[l][hash], l, hashIndex[l][hash], hash));
        }
      }

      while(true) {
        bool added;
        bool[] used = new bool[](N);
        foreach(hv; hashTree.array) {
          auto i = hv.index;
          auto l = hv.length;
          if (signals.length + l > LA) continue;

          auto uniqueNodes = route[i..min($, i + l)].dup.sort.uniq;
          if (uniqueNodes.any!(n => used[n])) continue;

          foreach(n; uniqueNodes) used[n] = true;
          indiciesForSignalHash[l][hv.hash] = signals.length.to!int;
          signals ~= uniqueNodes.array;
          added = true;
          hashTree.removeKey(hv);
        }

        if (!added) break;
      }

      signals ~= 0.repeat(LA).array;
      signals = signals[0..LA];

      indiciesForSignal[] = -1;
      foreach(i, s; signals.enumerate(0)) {
        if (indiciesForSignal[s] != -1) continue;

        indiciesForSignal[s] = i;
      }
    }

    Ans simulate() {
      int score;
      string ans = format("%(%d %) \n", signals);
      
      int[] visitable = (-1).repeat(LB).array;
      int offsetB;
      foreach(ti, t; route.enumerate(0)) {
        if (!visitable.canFind(t)) {
          auto rbt = new int[](0).redBlackTree;
          int sigLeft = indiciesForSignal[t];
          int sigSize = min(LA - sigLeft, LB);
          long hash;
          foreach(l; 1..LB + 1) {
            int ri = ti + l - 1;
            if (ri >= route.length) break;

            int rn = route[ri];
            if (!(rn in rbt)) {
              hash ^= rn.hashOf(seed);
              rbt.insert(rn);
            }

            if (hash in indiciesForSignalHash[l]) {
              sigLeft = indiciesForSignalHash[l][hash];
              sigSize = l;
            }
          }

          [ti, t, sigLeft].deb;

          auto offset = offsetB % 2 == 0 ? 0 : LB - sigSize;
          ans ~= format("s %d %d %d \n", sigSize, sigLeft, offset);
          offsetB++;
          visitable[offset..offset + sigSize] = signals[sigLeft..sigLeft + sigSize].dup;
          score++;
        }

        ans ~= format("m %d \n", t);
      }
      return Ans(score, ans);
    }
  }

  int[][] graphNormal = new int[][](N, 0);
  foreach(uv; UV) {
    graphNormal[uv[0]] ~= uv[1];
    graphNormal[uv[1]] ~= uv[0];
  }

  int[][] graphMST = new int[][](N, 0); {
    long countValue(int[] uv) { return T.count(uv[0]) + T.count(uv[1]); }
    UnionFind uf = UnionFind(N);
    foreach(uv; UV.sort!((a, b) => countValue(a) > countValue(b))) {
      if (uf.same(uv[0], uv[1])) continue;

      uf.unite(uv[0], uv[1]);
      graphMST[uv[0]] ~= uv[1];
      graphMST[uv[1]] ~= uv[0];
    }
  }
  
  auto ans = [
    new Simulator(graphNormal).simulate(),
    new Simulator(graphMST).simulate(),
  ];

  writeln(ans.minElement.output);
  ans.minElement.score.deb;
}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
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

struct UnionFind {
  int[] roots;
  int[] sizes;
  long[] weights;
 
  this(int size) {
    roots = size.iota.array;
    sizes = 1.repeat(size).array;
    weights = 0L.repeat(size).array;
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
    roots[rootY] = rootX;
    return true;
  }
 
  bool same(int x, int y, int w = 0) {
    int rootX = root(x);
    int rootY = root(y);
 
    return rootX == rootY && weights[rootX] - weights[rootY] == w;
  }
}
