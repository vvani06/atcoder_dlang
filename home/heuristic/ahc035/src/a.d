void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto RND = Xorshift(0);

  int N = scan!int;
  int M = scan!int;
  int T = scan!int;
  int SN = 2 * N * (N - 1);
  int NN = N * N;
  int[][] X = scan!int(SN * M).chunks(M).array;

  struct Seed {
    int id;
    int[] A;

    int memoPower, memoValue;

    int value() {
      if (memoValue > 0) return memoValue;
      return memoValue = A.sum;
    }

    int power() {
      if (memoPower > 0) return memoPower;
      return memoPower = A.map!"a ^^ 2".sum;
    }

    int norm(Seed other) {
      return zip(A, other.A).map!"(a[0] - a[1])^^2".sum;
    }
  }

  struct Sim {
    Seed[] seeds;

    int simulate(ref int[] cropped) {
      auto grid = cropped.chunks(N).array;

      int ret;
      foreach(r; 0..N) foreach(c; 0..N) {
        auto base = &seeds[grid[r][c]];

        if (c < N - 1) {
          auto other = &seeds[grid[r][c + 1]];
          ret = max(ret, base.value + other.value);
        }
        if (r < N - 1) {
          auto other = &seeds[grid[r + 1][c]];
          ret = max(ret, base.value + other.value);
        }
      }
      return ret;
    }

    int simulate2(ref int[] cropped) {
      auto grid = cropped.chunks(N).array;

      int ret;
      foreach(r; 0..N) foreach(c; 0..N) {
        auto base = &seeds[grid[r][c]];

        if (c < N - 1) {
          auto other = &seeds[grid[r][c + 1]];
          ret += base.power + other.power;
        }
        if (r < N - 1) {
          auto other = &seeds[grid[r + 1][c]];
          ret += base.power + other.power;
        }
      }
      return ret;
    }

    int simulate3(ref int[] cropped) {
      auto grid = cropped.chunks(N).array;

      int ret;

      ret += seeds[grid[0][0]].power * 2;
      ret += seeds[grid[N - 1][0]].power * 2;
      ret += seeds[grid[0][N - 1]].power * 2;
      ret += seeds[grid[N - 1][N - 1]].power * 2;
      
      foreach(n; 1..N - 1) {
        ret += seeds[grid[n][0]].power * 3;
        ret += seeds[grid[0][n]].power * 3;
        ret += seeds[grid[n][N - 1]].power * 3;
        ret += seeds[grid[N - 1][n]].power * 3;
      }

      foreach(r; 1..N - 1) foreach(c; 1..N - 1) {
        ret += seeds[grid[r][c]].power * 4;
      }

      return ret;
    }
  }

  foreach(t; 0..T) {
    Seed[] seeds = X.enumerate(0).map!(x => Seed(x[0], x[1])).array;
    seeds.sort!"a.power > b.power";
    auto sim = Sim(seeds);
    // auto simFunc = t % 2 == 1 ? &(sim.simulate2) : &(sim.simulate2);
    auto simFunc =&(sim.simulate3);

    // ランダムで初期解生成
    int bestScore;
    int[] bestArr;
    foreach(_; 0..200_000) {
      auto arr = NN.iota.array.randomShuffle(RND)[0..NN];
      if (bestScore.chmax(simFunc(arr))) {
        bestArr = arr.dup;
        // bestScore.deb;
      }
    }

    // 焼きなまし 意味なさそう
    // auto gridNums = NN.iota;
    // auto testArr = bestArr.dup;
    // foreach(_; 0..50_000) {
    //   auto toSwap = gridNums.randomSample(3, RND).array;
    //   testArr.swapAt(toSwap[0], toSwap[1]);
    //   testArr.swapAt(toSwap[1], toSwap[2]);
    //   auto score = simFunc(testArr);
    //   if (bestScore.chmax(score)) {
    //     bestScore.deb;
    //     bestArr = testArr.dup;
    //   }

    //   if (score < bestScore * 0.9) {
    //     testArr = bestArr.dup;
    //   }
    // }

    bestArr.deb;
    foreach(r; 0..N) {
      writefln("%(%s %)", bestArr[r * N..r * N + N].map!(s => seeds[s].id));
    }
    stdout.flush();
    X = scan!int(SN * M).chunks(M).array;
  }
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
