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
  long L = scan!long;
  long R = scan!long;

  long MAX = R - L;

  long[] A = L.repeat(M).array;
  long base = (MAX * 3) / 2;
  real ratio = 0.9655;
  foreach(_; iota(0, (N - M))) {
    A ~= base;
    base = (base.to!real * ratio).to!long;
  }

  writefln("%(%s %)", A);
  stdout.flush();

  long[] B = scan!long(M);

  int[] ans = new int[](N);
  long[] diffs = 0L ~ B.dup;
  foreach(bi, b; B.enumerate(1)) {
    long s;
    foreach(ai, a; A.enumerate(0)) {
      if (ans[ai] > 0) continue;

      if (s + a <= b) {
        s += a;
        diffs[bi] -= a;
        ans[ai] = bi;
      }
    }
  }
  foreach(bi; iota(1, M + 1).array.sort!((a, b) => diffs[a].abs > diffs[b].abs)) {
    foreach_reverse(ai, a; A.enumerate(0)) {
      if (ans[ai] > 0) continue;

      if (a - diffs[bi] < diffs[bi]) {
        diffs[bi] -= a;
        ans[ai] = bi;
      }
    }
  }

  auto sets = iota(M + 1).map!(m => iota(M, N).filter!(i => ans[i] == m).redBlackTree).array;
  // sets.each!deb;

  [[diffs.map!"a.abs".sum]].deb;

  struct State {
    int[] ans;
    long[] diffs;
    RedBlackTree!int[] sets;

    this(int[] an, long[] df) {
      ans = an.dup;
      diffs = df.dup;
      sets = iota(M + 1).map!(m => iota(M, N).filter!(i => ans[i] == m).redBlackTree).array;
    }

    State dup() {
      return State(ans, diffs);
    }

    long diffSum() {
      return diffs.map!"a.abs".sum;
    }

    int[] groupsLargerSorted() {
      return iota(1, M).array.sort!((a, b) => diffs[a] > diffs[b]).array;
    }

    int[] groupsSmallerSorted() {
      return iota(1, M).array.sort!((a, b) => diffs[a] < diffs[b]).array;
    }

    void randomRemove(int from) {
      foreach(_; 0..uniform(1, 3, RND)) {
        if (sets[from].empty) return;

        auto a = sets[from].array.choice(RND);
        sets[from].removeKey(a);
        sets[0].insert(a);
        ans[a] = 0;
        diffs[from] += A[a];
      }
    }

    void randomInsert(int to) {
      if (sets[to].empty) return;
      
      foreach(a; sets[0].array.randomShuffle(RND)) {
        if (diffs[to] < A[a]) continue;

        diffs[to] -= A[a];
        ans[a] = to;
        sets[to].insert(a);
        sets[0].removeKey(a);
      }
      foreach(a; sets[0].array.randomShuffle(RND)) {
        if (A[a] - diffs[to] > diffs[to]) continue;

        diffs[to] -= A[a];
        ans[a] = to;
        sets[to].insert(a);
        sets[0].removeKey(a);
      }
    }

    void outputAsAns() {
      writefln("%(%s %)", ans);
      stdout.flush();
    }
  }

  auto bestState = State(ans, diffs);
  auto state = State(ans, diffs);
  [[state.diffSum]].deb;

  MT: while(!elapsed(1900)) {
    auto froms = state.groupsLargerSorted()[0..1];
    foreach(from; froms.randomShuffle(RND)) {
      state.randomRemove(from);
    }
    foreach(from; froms.randomShuffle(RND)) {
      state.randomInsert(from);
    }
    
    if (bestState.diffSum > state.diffSum) {
      [[state.diffSum]].deb;
      bestState = state.dup;
    } else {
      state = bestState.dup;
    }
  }

  bestState.outputAsAns();
}

// ----------------------------------------------

import std;
import core.bitop;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(lazy T t){ debug { stderr.write("# "); stderr.writeln(t); }}
void debf(T ...)(lazy T t){ debug { stderr.write("# "); stderr.writefln(t); }}
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
