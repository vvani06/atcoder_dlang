void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto RND = Xorshift(0);
  enum long MOD = 998_244_353;
  enum long COST_WEIGHT = 500;
  enum int DFS_LIMIT = 3;

  int N = scan!int;
  int M = scan!int;
  int K = scan!int;
  long[] A = scan!long(N * N).array;
  long[][] S = scan!long(9 * M).chunks(9).array;

  struct Stamp {
    int type = 1, r, c;

    string toString() {
      return "%d %d %d".format(type, r, c);
    }
  }

  class State {
    long[] values;
    long modSum;
    Stamp[] stamps;

    this(long[] v) {
      values = v.dup;
      modSum = values.sum;
    }

    State dup() {
      auto duplicated = new State(values);
      duplicated.modSum = modSum;
      duplicated.stamps = stamps.dup;
      return duplicated;
    }

    long evaluate(Stamp s) {
      long ret;
      static foreach(dr; 0..3) static foreach(dc; 0..3) {{
        const i = (s.r + dr)*N + s.c + dc;
        const j = dr*3 + dc;
        ret += (values[i] + S[s.type][j]) % MOD - values[i];
      }}
      return ret;
    }

    long evaluateRight(Stamp s) {
      long ret;
      enum dc = 2;
      static foreach(dr; 0..3) {{
        const i = (s.r + dr)*N + s.c + dc;
        const j = dr*3 + dc;
        ret += (values[i] + S[s.type][j]) % MOD;
      }}
      return ret;
    }

    long addAndEvaluateRight(Stamp s) {
      stamps ~= s;
      long ret;
      static foreach(dr; 0..3) static foreach(dc; 0..3) {{
        const i = (s.r + dr)*N + s.c + dc;
        const j = dr*3 + dc;
        modSum -= values[i];
        modSum += values[i] = (values[i] + S[s.type][j]) % MOD;

        if (dc == 2) {
          ret += (values[i] + S[s.type][j]) % MOD;
        }
      }}
      return ret;
    }

    bool add(Stamp s) {
      if (stamps.length >= K) return false;

      stamps ~= s;
      static foreach(dr; 0..3) static foreach(dc; 0..3) {{
        const i = (s.r + dr)*N + s.c + dc;
        const j = dr*3 + dc;
        modSum -= values[i];
        modSum += values[i] = (values[i] + S[s.type][j]) % MOD;
      }}
      return true;
    }

    void remove(int stampIndex) {
      auto s = stamps[stampIndex];
      stamps = stamps[0..stampIndex] ~ stamps[stampIndex + 1..$];

      static foreach(dr; 0..3) static foreach(dc; 0..3) {{
        const i = (s.r + dr)*N + s.c + dc;
        const j = dr*3 + dc;
        modSum -= values[i];
        modSum += values[i] = (values[i] + MOD - S[s.type][j]) % MOD;
      }}
    }

    void printAns() {
      stamps.length.writeln;
      foreach(s; stamps) s.writeln;
    }
  }

  State initStateR = new State(A);
  State initStateB = new State(A);

  // 縦を3つに割って、右端から最大4回のスタンプを全通り試して最大化する
  // ここまでで 21 * 4 = 84回
  foreach(r; [0, 2, 4, 6]) foreach(c; iota(6, -1, -1)) {
    auto size = r == 6 ? 3 : 2;
    DList!int stamps;
    int[] bestStamps;
    long[] rights = size.iota.map!(d => initStateR.values[(r + d)*N + c + 2]).array;
    long bestRight = rights.sum;

    void dfs(int type, int count) {
      if (bestRight.chmax(rights.sum * 10000L / (10000L + count * COST_WEIGHT))) bestStamps = stamps.array;
      if (count >= min(DFS_LIMIT, K - initStateB.stamps.length)) return;

      foreach(t; type..M) {
        stamps.insertBack(t);
        foreach(d; 0..size) {
          rights[d] = (rights[d] + S[t][3 * d + 2]) % MOD;
        }
        dfs(type, count + 1);
        foreach(d; 0..size) {
          rights[d] = (rights[d] + MOD - S[t][3 * d + 2]) % MOD;
        }
        stamps.removeBack();
      }
    }

    dfs(0, 0);
    foreach(s; bestStamps) {
      initStateR.add(Stamp(s, r, c));
    }
  }

  // 左端に絞って、下から最大化する
  foreach(r; iota(6, -1, -1)) {
    DList!int stamps;
    int[] bestStamps;
    const b = (r + 2) * N;
    long[] bottoms = initStateR.values[b..b + 3];
    long bestBottom = bottoms.sum;

    void dfs(int type, int count) {
      if (bestBottom.chmax(bottoms.sum * 10000L / (10000L + count * COST_WEIGHT))) bestStamps = stamps.array;
      if (count >= min(DFS_LIMIT, K - initStateR.stamps.length)) return;

      foreach(t; type..M) {
        stamps.insertBack(t);
        foreach(d; 0..3) {
          bottoms[d] = (bottoms[d] + S[t][6 + d]) % MOD;
        }
        dfs(type, count + 1);
        foreach(d; 0..3) {
          bottoms[d] = (bottoms[d] + MOD - S[t][6 + d]) % MOD;
        }
        stamps.removeBack();
      }
    }

    dfs(0, 0);
    foreach(s; bestStamps) {
      initStateR.add(Stamp(s, r, 0));
    }
  }

  // ↑の処理と縦横の順を反転させたバージョン
  foreach(r; iota(6, -1, -1)) foreach(c; [0, 2, 4, 6]) {
    auto size = c == 6 ? 3 : 2;
    DList!int stamps;
    int[] bestStamps;
    const b = (r + 2) * N + c;
    long[] bottoms = initStateB.values[b..b + size];
    long bestBottom = bottoms.sum;

    void dfs(int type, int count) {
      if (bestBottom.chmax(bottoms.sum * 10000L / (10000L + count * COST_WEIGHT))) bestStamps = stamps.array;
      if (count >= min(DFS_LIMIT, K - initStateB.stamps.length)) return;

      foreach(t; type..M) {
        stamps.insertBack(t);
        foreach(d; 0..size) {
          bottoms[d] = (bottoms[d] + S[t][6 + d]) % MOD;
        }
        dfs(type, count + 1);
        foreach(d; 0..size) {
          bottoms[d] = (bottoms[d] + MOD - S[t][6 + d]) % MOD;
        }
        stamps.removeBack();
      }
    }

    dfs(0, 0);
    foreach(s; bestStamps) {
      initStateB.add(Stamp(s, r, c));
    }
  }
  foreach(r; [0]) foreach(c; iota(6, -1, -1)) {
    DList!int stamps;
    int[] bestStamps;
    long[] rights = 3.iota.map!(d => initStateB.values[(r + d)*N + c + 2]).array;
    long bestRight = rights.sum;

    void dfs(int type, int count) {
      if (bestRight.chmax(rights.sum * 10000L / (10000L + count * COST_WEIGHT))) bestStamps = stamps.array;
      if (count >= min(DFS_LIMIT, K - initStateB.stamps.length)) return;

      foreach(t; type..M) {
        stamps.insertBack(t);
        static foreach(d; 0..3) {{
          rights[d] = (rights[d] + S[t][3 * d + 2]) % MOD;
        }}
        dfs(type, count + 1);
        static foreach(d; 0..3) {{
          rights[d] = (rights[d] + MOD - S[t][3 * d + 2]) % MOD;
        }}
        stamps.removeBack();
      }
    }

    dfs(0, 0);
    foreach(s; bestStamps) {
      initStateB.add(Stamp(s, r, c));
    }
  }

  auto initState = initStateR.dup;
  if (initStateB.modSum > initState.modSum) initState = initStateB.dup;

  State bestState = initState.dup;
  while(!elapsed(1970)) {
    auto state = initState.dup;

    // foreach(rem; 0..iota(0, min(4, state.stamps.length)).choice(RND)) {
    //   foreach(r; 0..rem) {
    //     auto l = state.stamps.length.to!int;
    //     state.remove(l.iota.choice(RND));
    //   }
    // }

    foreach(l; 0..K - state.stamps.length) {
      auto t = M.iota.choice(RND);
      auto r = 1.iota.choice(RND);
      auto c = 1.iota.choice(RND);
      state.add(Stamp(t, r, c));

      if (bestState.modSum < state.modSum) {
        auto bef = bestState.modSum;
        bestState = state.dup;
        deb(bef, " => ", bestState.modSum);
      }
    }
  }

  stderr.writefln("Score = %d", bestState.modSum);
  bestState.printAns();
}

// ----------------------------------------------

import std;
import core.memory : GC;
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
  problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
