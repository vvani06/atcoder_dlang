void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  struct Color {
    double c, m, y;

    double[] asArray() { return [c, m, y]; }

    double delta(Color other) {
      return pow(c - other.c, 2) + pow(m - other.m, 2) + pow(y - other.y, 2);
    }
  }

  int N = scan!int;
  int K = scan!int;
  int H = scan!int;
  int T = scan!int;
  int D = scan!int;
  Color[] OWN = K.iota.map!(_ => Color(scan!double, scan!double, scan!double)).array;
  Color[] TARGET = H.iota.map!(_ => Color(scan!double, scan!double, scan!double)).array;

  foreach(_; 0..N) {
    writefln("%(%s %)", 1.repeat(N - 1));
  }
  foreach(_; 1..N) {
    writefln("%(%s %)", 0.repeat(N));
  }

  struct Well {
    int id;
    double size;
    Color color;
    
    Well add(double otherSize, Color otherColor) {
      auto newSize = size + otherSize;
      return Well(
        id,
        newSize,
        Color(
          (color.c * size + otherColor.c * otherSize) / newSize,
          (color.m * size + otherColor.m * otherSize) / newSize,
          (color.y * size + otherColor.y * otherSize) / newSize,
        ),
      );
    }

    inout int opCmp(inout Well other) {
      return cmp(
        [id, size],
        [other.id, other.size],
      );
    }
  }

  class State {
    Well[int] palette;
    int nextWellId;
    int nextTargetIndex;
    long useColorCount;
    double colorDeltaSum;
    string[] commands;
    State preState;

    this() {
      colorDeltaSum = sqrt(3.0) * H;
    }

    State dup(bool deep = false) {
      State ret = new State();
      ret.palette = palette.dup;
      ret.nextWellId = nextWellId;
      ret.nextTargetIndex = nextTargetIndex;
      ret.useColorCount = useColorCount;
      ret.colorDeltaSum = colorDeltaSum;
      if (deep) {
        ret.preState = this.preState;
        ret.commands = commands.dup;
      } else {
        ret.preState = this;
      }
      return ret;
    }

    void newWell(int colorId) {
      palette[nextWellId] = Well(nextWellId, 1, OWN[colorId]);
      commands ~= "1 %s %s %s".format(nextWellId / N, nextWellId % N, colorId);
      nextWellId = (nextWellId + 1) % N;
      useColorCount++;
    }

    void addWell(int wellId, int colorId) {
      palette[wellId] = palette[wellId].add(1, OWN[colorId]);
      commands ~= "1 %s %s %s".format(wellId / N, wellId % N, colorId);
      useColorCount++;
    }

    void submitBestColor() {
      if (nextTargetIndex == H) return;
      auto target = TARGET[nextTargetIndex];

      double bestDelta = int.max;
      int bestWell;
      foreach(w, well; palette) {
        if (well.size >= 1.0 && bestDelta.chmin(target.delta(well.color))) bestWell = w;
      }

      if (bestDelta == int.max) return;

      palette[bestWell].size -= 1.0;
      if (palette[bestWell].size.isClose(0, 0.00001)) palette.remove(bestWell);
      nextTargetIndex++;
      colorDeltaSum += sqrt(bestDelta) - sqrt(3.0);
      commands ~= "2 %s %s".format(bestWell / N, bestWell % N);
    }

    double potential() {
      double ret = 0;
      int[] used = new int[](N);
      for(auto t = nextTargetIndex; t < min(H, nextTargetIndex + 2); t++) {
        auto target = TARGET[t];
        double bestDelta = int.max;
        int bestWell;
        foreach(w, well; palette) {
          if (well.size - used[w] >= 1.0 && bestDelta.chmin(target.delta(well.color))) bestWell = w;
        }

        if (bestDelta == int.max) break;
        ret += sqrt(bestDelta) - sqrt(3.0);
        used[bestWell]++;
      }

      return ret;
    }


    double calcedScore;
    double calcScore() {
      if (calcedScore !is double.nan) return calcedScore;
      return calcedScore = 1
        + useColorCount * D
        + colorDeltaSum * 10^^4
        + potential() * 10^^4
      ;
    }

    State[] simulateStep(bool addOnly = false) {
      State[] ret;
      if (!addOnly) foreach(i; 0..K) {
        auto state = this.dup();
        state.newWell(i);
        ret ~= state;
      }

      foreach(to; palette.keys) {
        foreach(i; 0..K) {
          auto state = this.dup();
          state.addWell(to, i);
          ret ~= state;
        }
      }
      return ret;
    }
  }

  State ans = new State();
  ans.useColorCount = 10^^5;
  auto states = [new State()];
  auto states2 = [new State()];

  enum BEAM_BANDWIDTH = 2;

  foreach(_; 0..H * 3) {
    State[] nextStates;
    foreach(ref fromStates; [states, states2]) {
      foreach(preState; fromStates.sort!"a.calcScore < b.calcScore"[0..min($, BEAM_BANDWIDTH)]) {
        auto sim = preState.simulateStep();
        nextStates ~= sim;
      }
    }

    nextStates.length.deb;
    states2 = nextStates.map!"a.dup(true)".array;
    foreach(i; 0..nextStates.length) {
      nextStates[i].submitBestColor();
      if (nextStates[i].nextTargetIndex == H && ans.calcScore() > nextStates[i].calcScore()) {
        ans = nextStates[i];
      }
    }

    states = nextStates;
  }

  ans.calcScore().deb;
  string[][] commands;
  while(ans !is null) {
    commands ~= ans.commands;
    ans = ans.preState;
  }

  foreach(cs; commands.retro) {
    foreach(c; cs) writeln(c);
  }
}

// ----------------------------------------------

import std;
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
