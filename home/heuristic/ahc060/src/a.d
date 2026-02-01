void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int M = scan!int;
  int K = scan!int;
  int T = scan!int;
  int[][] E = scan!int(2 * M).chunks(2).array;

  int[][] graph = new int[][](N, 0);
  foreach(u, v; E.asTuples!2) {
    graph[u] ~= v;
    graph[v] ~= u;
  }

  int[][][] rests = new int[][][](N, N, 0);
  rests[0][0] = graph[0];
  foreach(node; 0..N) {
    foreach(u; graph[node]) foreach(v; graph[node]) {
      if (u != v) rests[node][u] ~= v;
    }
  }

  bool[BitArray][] stocks;
  stocks.length = K;
  bool[] isWhite = new bool[](N);

  bool isShop(int node) {
    return node < K;
  }

  int cur = 0;
  int pre = 0;
  bool[] corn;
  foreach(turn; 0..T) {
    if (!isShop(cur) && !isWhite[cur] && uniform(0.0, 1.0, RND) <= (turn.to!double / T)^^4) {
      isWhite[cur] = true;
      writeln(-1);
      continue;
    }

    int next = -1;
    foreach(s; rests[cur][pre]) {
      if (!isShop(s)) continue;

      auto ba = BitArray(corn);
      if (ba !in stocks[s]) {
        next = s;
        break;
      }
    }

    if (next == -1) {
      foreach(_; 0..10) {
        next = rests[cur][pre].choice(RND);
        
        if (isShop(next)) {
          auto ba = BitArray(corn);
          if (ba in stocks[next]) continue;
        }
      }
    }

    if (isShop(next)) {
      auto ba = BitArray(corn);
      if (ba in stocks[next]) {
        deb("dup ice");
      }
      stocks[next][ba] = true;
      corn.length = 0;
    } else {
      corn ~= isWhite[next];
    }

    writeln(next);
    pre = cur;
    cur = next;
  }

}

// ----------------------------------------------

import std;
import core.bitop;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(lazy T t){ debug { write("# "); writeln(t); }}
void debf(T ...)(lazy T t){ debug { write("# "); writefln(t); }}
// void deb(T ...)(T t){ debug {  }}
T[] divisors(T)(T n) { T[] ret; for (T i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == float) || is(T == double) || is(T == float)) "%.16f".writefln(fn());
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

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}
