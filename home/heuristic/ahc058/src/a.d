void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int L = scan!int;
  int T = scan!int;
  int K = scan!int;
  long[] A = scan!long(N);
  long[][] C = scan!long(N * L).chunks(N).array;

  string[] bestAns;
  real bestScore = 0;

  while(!elapsed(1800)) {
    string[] ans;
    auto filtered = 0 ~ iota(1, N).array.randomShuffle(RND)[0..3].array;

    real apple = 1.00001;
    real velocity = 0;
    long[][] powers = new long[][](N, L);
    real[][] machines = new real[][](N, L);
    foreach(ref m; machines) m[] = 1;

    real linearPerformance(int id, int level) {
      return A[id].to!real / C[level][id];
    }

    int potential(int id) {
      int ret;
      foreach(level; 0..L) {
        auto s = iota(N).array.sort!((a, b) => linearPerformance(a, level) > linearPerformance(b, level));
        ret += (11 - s.countUntil(id));
      }
      return ret;
    }

    real cost(int id, int level) {
      return C[level][id] * (powers[id][level] + 1);
    }
    
    string amplify(int id, int level) {
      foreach(l; 0..level) {
        if (powers[id][l] <= powers[id][level]) {
          level = l;
          break;
        }
      }
      apple -= cost(id, level);
      powers[id][level] += 1;
      return "%s %s".format(level, id);
    }

    foreach(turn; 0..T) {
      real performance(int id, int level) {
        real value = 0;
        if (level == 0) {
          value = A[id] * machines[id][0];
        } else {
          value = pow(A[id] * (powers[id][0] + 3), level);
        }
        auto rest = T - turn;
        auto turnsNeeded = max(0, cost(id, level) - apple) / velocity;
        return value * max(0, rest - turnsNeeded) - cost(id, level);
      }

      string output = "-1";
      LEVEL: foreach(level; iota(L - 1, -1, -1)) {
        TARGET: foreach(target; filtered.sort!((a, b) => performance(a, level) > performance(b, level))) {
          if (apple >= cost(target, level)) {
            output = amplify(target, level);
            break LEVEL;
          }
        }
      }
      ans ~= output;

      real pre = apple;
      foreach(id; 0..N) {
        apple += machines[id][0] * powers[id][0] * A[id];
        foreach(level; 1..L) {
          machines[id][level - 1] += machines[id][level] * powers[id][level];
        }
      }
      velocity = apple - pre;
    }

    if (bestScore.chmax(apple)) {
      bestAns = ans;
    }
  }

  bestScore.deb;
  foreach(a; bestAns) writeln(a);
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
