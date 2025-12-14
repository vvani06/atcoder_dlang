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

  real apple = 1.00001;
  real velocity = 0;
  long[][] powers = new long[][](N, L);
  real[][] machines = new real[][](N, L);
  foreach(ref m; machines) m[] = 1;

  real cost(int id, int level) {
    return C[level][id] * (powers[id][level] + 1);
  }

  string amplify(int id, int level) {
    apple -= cost(id, level);
    powers[id][level] += 1;
    return "%s %s".format(level, id);
  }

  foreach(turn; 0..T) {

    real performance(int id) {
      auto rest = T - turn;
      auto turnsNeeded = max(0, cost(id, 0) - apple) / velocity;
      auto value = A[id] * (rest - turnsNeeded);
      return value / cost(id, 0);
    }

    auto targets = iota(N).array.sort!((a, b) => performance(a) > performance(b));
    targets.deb;

    string output = "-1";
    TARGET: foreach(target; targets) {
      foreach(level; iota(L - 1, -1, -1)) {
        if (apple >= cost(target, level)) {
          output = amplify(target, level);
          break TARGET;
        }
      }
    }
    [apple.to!long].deb;
    writeln(output);

    real pre = apple;
    foreach(id; 0..N) {
      apple += machines[id][0] * powers[id][0] * A[id];
      foreach(level; 1..L) {
        machines[id][level - 1] += machines[id][level] * powers[id][level];
      }
    }
    velocity = apple - pre;
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
