void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto RND = Xorshift(0);
  enum long MOD = 998_244_353;

  int N = scan!int;
  int M = scan!int;
  int K = scan!int;
  long[] A = scan!long(N * N).array;
  long[][] S = scan!long(9 * M).chunks(9).array;
  S ~= 0L.repeat(9).array;

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

  bool addOneStampGreedy(State state) {
    long best;
    Stamp bestStamp;
    foreach(t; 0..M) foreach(r; 0..N - 3) foreach(c; 0..N - 3) {
      auto stamp = Stamp(t, r, c);
      if (best.chmax(state.evaluate(stamp))) bestStamp = stamp;
    }

    if (best <= 0) return false;

    state.add(bestStamp);
    return true;
  }

  State initState = new State(A);



  foreach(r; [0, 3, 6]) foreach(c; iota(6, -1, -1)) {
    DList!int stamps;
    int[] bestStamps;
    State state = initState.dup;
    long[] rights = 3.iota.map!(d => initState.values[(r + d)*N + c + 2]).array;
    long bestRight = rights.sum;

    void dfs(int type, int count) {
      if (bestRight.chmax(rights.sum)) bestStamps = stamps.array;
      if (count >= 4) return;

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
      initState.add(Stamp(s, r, c));
    }
  }

  // foreach(_; 0..K) {
  //   if (!addOneStampGreedy(initState)) break;
  // }

  State bestState = initState.dup;
  // while(!elapsed(1900)) {
  //   auto state = initState.dup;

  //   foreach(rem; 0..iota(0, min(5, state.stamps.length)).choice(RND)) {
  //     foreach(r; 0..rem) {
  //       auto l = state.stamps.length.to!int;
  //       state.remove(l.iota.choice(RND));
  //     }
  //   }

  //   foreach(l; 0..K - state.stamps.length) {
  //     auto t = M.iota.choice(RND);
  //     auto r = (N - 3).iota.choice(RND);
  //     auto c = (N - 3).iota.choice(RND);
  //     state.add(Stamp(t, r, c));

  //     if (bestState.modSum < state.modSum) {
  //       auto bef = bestState.modSum;
  //       bestState = state.dup;
  //       deb(bef, " => ", bestState.modSum);
  //     }
  //   }
  // }

  bestState.modSum.deb;
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
