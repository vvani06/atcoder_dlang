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
  long[][] X = scan!long(SN * M).chunks(M).array;

  struct Seed {
    int id;
    long[] A;

    long memoPower, memoValue;

    long value() {
      if (memoValue > 0) return memoValue;
      return memoValue = A.sum;
    }

    long power() {
      if (memoPower > 0) return memoPower;
      return memoPower = A.sum + A.map!"a ^^ 2".sum;
    }

    long power2(long[] maxes) {
      return  A.map!"a ^^ 3".sum;
    }
  }

  struct Sim {
    Seed[] seeds;
    long basePower;

    this(Seed[] s) {
      seeds = s;
      basePower = s.map!"a.power".sum * 4;
    }

    long simulate(ref int[] cropped) {
      auto grid = cropped.chunks(N).array;

      long ret;
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

    long simulate2(ref int[] cropped) {
      auto grid = cropped.chunks(N).array;

      long ret;
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

    long simulate3(ref int[] cropped) {
      auto grid = cropped.chunks(N).array;

      long ret;
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

    long simulate4(ref int[] cropped) {
      auto grid = cropped.chunks(N).array;

      long sub;
      sub += seeds[grid[0][0]].power * 2;
      sub += seeds[grid[N - 1][0]].power * 2;
      sub += seeds[grid[0][N - 1]].power * 2;
      sub += seeds[grid[N - 1][N - 1]].power * 2;
      static foreach(n; 1..5) {
        sub += seeds[grid[n][0]].power;
        sub += seeds[grid[0][n]].power;
        sub += seeds[grid[n][N - 1]].power;
        sub += seeds[grid[N - 1][n]].power;
      }
      return basePower - sub;
    }

    long simulate5(ref int[] cropped, int rem) {
      auto grid = cropped.chunks(N).array;

      long sub;
      sub += seeds[grid[0][0]].power * 2;
      sub += seeds[grid[N - 1][0]].power * 2;
      sub += seeds[grid[0][N - 1]].power * 2;
      sub += seeds[grid[N - 1][N - 1]].power * 2;
      static foreach(n; 1..5) {
        sub += seeds[grid[n][0]].power;
        sub += seeds[grid[0][n]].power;
        sub += seeds[grid[n][N - 1]].power;
        sub += seeds[grid[N - 1][n]].power;
      }
      return basePower - sub + simulate(cropped) * NN * 8 / rem;
    }
  }

  foreach(_t; 0..T) {
    Seed[] seeds = X.enumerate(0).map!(x => Seed(x[0], x[1])).array;
    {
      auto maxes = M.iota.map!(i => seeds.map!(a => a.A[i]).maxElement).array;
      seeds.sort!((a, b) => a.power2(maxes) > b.power2(maxes));
      
      auto tops = new int[][](SN, 0);
      foreach(s; 0..SN) foreach(i; 0..M) {
        if (seeds[s].A[i] == maxes[i]) tops[s] ~= i;
      }

      bool[] usedM = new bool[](M);
      bool[] usedS = new bool[](SN);
      while(usedM.canFind(false)) {
        int maxi = -1;
        int maxim = -1;
        foreach(i; 0..SN) {
          if (usedS[i]) continue;

          auto l = tops[i].count!(m => !usedM[m]).to!int;
          if (maxim.chmax(l)) maxi = i;
        }

        usedS[maxi] = true;
        foreach(m; tops[maxi]) {
          usedM[m] = true;
        }
      }
      usedM.deb;
      usedS.deb;

      auto topSeeds = SN.iota.filter!(s => usedS[s]).map!(s => seeds[s]).array;
      auto remSeeds = SN.iota.filter!(s => !usedS[s]).map!(s => seeds[s]).array;
      seeds = topSeeds ~ remSeeds.array;
    }

    auto sim = Sim(seeds);
    auto simFunc = &(sim.simulate5);

    // ランダムで初期解生成
    long bestScore;
    int[] bestArr;
    foreach(_; 0..150_000) {
      auto arr = NN.iota.array.randomShuffle(RND)[0..NN];
      if (bestScore.chmax(simFunc(arr, 10 - _t))) {
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
    X = scan!long(SN * M).chunks(M).array;
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
