void main() { runSolver(); }

// ----------------------------------------------

struct Coord {
  int x, y;
}

struct Game {
  int L;
  int N;
  int S;
  Coord[] P;
  
  bool[][] isHole;
  Coord[] aroundCoords;

  int creekSize;
  int sampleSize;
  int sampleStep;
  int[] samples;

  this(int l, int n, int s, Coord[] p) {
    L = l;
    N = n;
    S = s;
    P = p;

    isHole = new bool[][](L, L);
    foreach(c; P) isHole[c.y][c.x] = true;
    aroundCoords = availableAroundCoords();
    
    sampleSize = max(2, min(N, 1200 / S));
    while(sampleSize^^creekSize < N && creekSize < aroundCoords.length) creekSize++;

    if (sampleSize^^creekSize < N) {
      creekSize = aroundCoords.length.to!int;
      while(sampleSize^^creekSize < N) sampleSize++;
    }

    while ((sampleSize - 1)^^creekSize >= N) sampleSize--;

    int maxColor = min(1000, (S * sampleSize * 3).to!int);
    sampleStep = maxColor / (sampleSize - 1);
    samples = iota(0, maxColor + 1, sampleStep).array;

    int[] odds, evens;
    foreach(i; 0..sampleSize) {
      if (i % 2 == 0) odds ~= samples[i]; else evens ~= samples[i];
    }
    samples = odds ~ evens.reverse.array;

    [creekSize, sampleSize, sampleStep].deb;
    samples.deb;
  }

  int[] asCreek(int id) {
    int[] ret = new int[](creekSize);
    foreach(i; 0..creekSize) {
      ret[i] = id % sampleSize;
      id /= sampleSize;
    }
    return ret.reverse.array;
  }

  Coord[] availableAroundCoords() {
    auto AROUND_SIZE = L / 5;
    int[Coord] badCount;
    foreach(dy; -AROUND_SIZE..AROUND_SIZE + 1) foreach(dx; -AROUND_SIZE..AROUND_SIZE + 1) badCount[Coord(dx, dy)] = 0;

    foreach(c; P) {
      foreach(dy; -AROUND_SIZE..AROUND_SIZE + 1) foreach(dx; -AROUND_SIZE..AROUND_SIZE + 1) {
        auto y = (c.y + dy + L) % L;
        auto x = (c.x + dx + L) % L;
        if (isHole[y][x]) badCount[Coord(dx, dy)]++;
      }
    }

    badCount[Coord(0, 0)] = -1;
    auto coords = badCount.keys.filter!(a => badCount[a] <= 16).array.multiSort!(
      (a, b) => badCount[a] < badCount[b],
      (a, b) => abs(a.x) + abs(a.y) < abs(b.x) + abs(b.y),
    );
    coords.deb;
    coords.map!(a => [badCount[a]]).deb;
    return coords.array[0..min($, 24)];
  }

  static Game instance;
}

struct Hole {
  int id;
  Coord coord;

  int[] asCreek() {
    return Game.instance.asCreek(id);
  }
}

class Measurement {
  int[][] measured;

  this() {
    measured = new int[][](Game.instance.creekSize, 0);
  }

  real add(int creekId, int value) {
    measured[creekId] ~= value;
    
    if (measured[creekId].length < 6) return 0;

    const creekSize = Game.instance.creekSize;
    const sampleSize = Game.instance.sampleSize;
    const samples = Game.instance.samples;

    auto scores = new long[](sampleSize);
    foreach(m; measured[creekId]) {
      foreach(s; 0..sampleSize) {
        scores[s] += abs(samples[s] - m)^^2;
      }
    }

    // samples.deb;
    // scores.deb;
    // sampleSize.iota.map!(i => [scores[i], samples[i]]).array.sort!"a[0] < b[0]".deb;
    scores.sort;
    auto top = scores[0].to!real;
    auto second = scores[1].to!real;
    return 1.0 - (top / second);
  }

  real[] zAssume() {
    const creekSize = Game.instance.creekSize;
    const sampleSize = Game.instance.sampleSize;
    const samples = Game.instance.samples;

    // enum real[] zTable = [0.5,0.496011,0.492022,0.488033,0.484047,0.480061,0.476078,0.472097,0.468119,0.464144,0.460172,0.456205,0.452242,0.448283,0.44433,0.440382,0.436441,0.432505,0.428576,0.424655,0.42074,0.416834,0.412936,0.409046,0.405165,0.401294,0.397432,0.39358,0.389739,0.385908,0.382089,0.378281,0.374484,0.3707,0.366928,0.363169,0.359424,0.355691,0.351973,0.348268,0.344578,0.340903,0.337243,0.333598,0.329969,0.326355,0.322758,0.319178,0.315614,0.312067,0.308538,0.305026,0.301532,0.298056,0.294598,0.29116,0.28774,0.284339,0.280957,0.277595,0.274253,0.270931,0.267629,0.264347,0.261086,0.257846,0.254627,0.251429,0.248252,0.245097,0.241964,0.238852,0.235762,0.232695,0.22965,0.226627,0.223627,0.22065,0.217695,0.214764,0.211855,0.20897,0.206108,0.203269,0.200454,0.197662,0.194894,0.19215,0.18943,0.186733,0.18406,0.181411,0.178786,0.176186,0.173609,0.171056,0.168528,0.166023,0.163543,0.161087,0.158655,0.156248,0.153864,0.151505,0.14917,0.146859,0.144572,0.14231,0.140071,0.137857,0.135666,0.1335,0.131357,0.129238,0.127143,0.125072,0.123024,0.121001,0.119,0.117023,0.11507,0.11314,0.111233,0.109349,0.107488,0.10565,0.103835,0.102042,0.100273,0.098525,0.096801,0.095098,0.093418,0.091759,0.090123,0.088508,0.086915,0.085344,0.083793,0.082264,0.080757,0.07927,0.077804,0.076359,0.074934,0.073529,0.072145,0.070781,0.069437,0.068112,0.066807,0.065522,0.064256,0.063008,0.06178,0.060571,0.05938,0.058208,0.057053,0.055917,0.054799,0.053699,0.052616,0.051551,0.050503,0.049471,0.048457,0.04746,0.046479,0.045514,0.044565,0.043633,0.042716,0.041815,0.040929,0.040059,0.039204,0.038364,0.037538,0.036727,0.03593,0.035148,0.034379,0.033625,0.032884,0.032157,0.031443,0.030742,0.030054,0.029379,0.028716,0.028067,0.027429,0.026803,0.02619,0.025588,0.024998,0.024419,0.023852,0.023295,0.02275,0.022216,0.021692,0.021178,0.020675,0.020182,0.019699,0.019226,0.018763,0.018309,];

    auto scoresPerCreek = new real[][](creekSize, sampleSize);
    foreach(creekId; 0..creekSize) {
      scoresPerCreek[creekId][] = 1.0;
      real se = 1000.0 * Game.instance.S.to!real / measured[creekId].length.to!real.sqrt;
      real x = measured[creekId].mean;

      foreach(si, sv; samples) {
        scoresPerCreek[creekId][si] = (x - sv.to!real).abs / se;
      }
    }

    auto ret = new real[](Game.instance.N);
    ret[] = 1.0;
    foreach(v; 0..Game.instance.N) {
      foreach(c; 0..creekSize) {
        auto d = sampleSize ^^ (creekSize - c - 1);
        ret[v] *= scoresPerCreek[c][(v / d) % sampleSize];
      }
    }

    ret.deb;
    return ret;
  }

  int assume() {
    const creekSize = Game.instance.creekSize;
    const sampleSize = Game.instance.sampleSize;
    const samples = Game.instance.samples;

    int ret;
    foreach(i; 0..creekSize) {
      ret *= sampleSize;

      auto scores = new long[](sampleSize);
      foreach(m; measured[i]) {
        foreach(s; 0..sampleSize) {
          scores[s] += abs(samples[s] - m)^^2;
        }
      }
      scores.deb;
      ret += scores.minIndex;
    }

    measured.deb;
    ret.deb;
    return min(Game.instance.N - 1, ret);
  }
}

void problem() {
  auto L = scan!int;
  auto N = scan!int;
  auto S = scan!int;
  auto P = scan!int(2 * N).chunks(2).map!(c => Coord(c[1], c[0])).array;
  Game.instance = Game(L, N, S, P);
  
  auto RND = Xorshift(unpredictableSeed);

  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

  enum P_EMPTY = -1;
  enum MEASURE_TIMES_MAX = 10000;

  auto solve() {
    Hole[] holes; foreach(i, p; P) {
      holes ~= Hole(i.to!int, p);
      // holes[$ - 1].deb;
      // holes[$ - 1].asCreek.deb;
    }

    Coord[] bestCoords = Game.instance.aroundCoords[0..1];
    auto heatmap = new int[][](L, L); {
      int best = int.max;
      foreach(comb; Game.instance.aroundCoords[1..$].combinations(Game.instance.creekSize - 1)) {
        int conflicts;
        comb = Game.instance.aroundCoords[0] ~ comb;
        auto used = new bool[][](L, L);
        foreach(h; holes) {
          auto creeks = h.asCreek;

          bool conflicted;
          foreach(i; 0..Game.instance.creekSize) {
            auto d = comb[i];
            auto x = (h.coord.x + d.x + L) % L;
            auto y = (h.coord.y + d.y + L) % L;
            if (used[y][x]) {
              conflicted = true;
              break;
            }
          }
          if (conflicted) {
            conflicts += 1;
            continue;
          }

          foreach(i; 0..Game.instance.creekSize) {
            auto d = comb[i];
            auto x = (h.coord.x + d.x + L) % L;
            auto y = (h.coord.y + d.y + L) % L;
            if (!used[y][x]) {
              used[y][x] = true;
            }
          }
        }
        
        if (best.chmin(conflicts)) bestCoords = comb;
      }
      best.deb;
      bestCoords.deb;

      auto stable = new bool[][](L, L);
      foreach(ref h; heatmap) h[] = P_EMPTY;

      alias Fill = Tuple!(int, "x", int, "y", int, "color");
      auto queue = DList!Fill();
      foreach(h; holes) {
        auto creeks = h.asCreek;

        bool conflicted;
        foreach(i; 0..Game.instance.creekSize) {
          auto d = bestCoords[i];
          auto x = (h.coord.x + d.x + L) % L;
          auto y = (h.coord.y + d.y + L) % L;
          if (heatmap[y][x] != P_EMPTY) {
            conflicted = true;
            break;
          }
        }
        if (conflicted) continue;

        foreach(i; 0..Game.instance.creekSize) {
          auto d = bestCoords[i];
          auto x = (h.coord.x + d.x + L) % L;
          auto y = (h.coord.y + d.y + L) % L;
          if (heatmap[y][x] == P_EMPTY) {
            heatmap[y][x] = Game.instance.samples[creeks[i]];
            queue.insertBack(Fill(x, y, Game.instance.samples[creeks[i]]));
            stable[y][x] = true;
          }
        }
      }

      // 未使用のマスをBFSで塗り広げる
      while(!queue.empty) {
        auto p = queue.front; queue.removeFront;
        
        foreach(dx, dy; zip([-1, 0, 1, 0], [0, -1, 0 ,1])) {
          auto x = (p.x + dx + L) % L;
          auto y = (p.y + dy + L) % L;
          if (heatmap[y][x] != P_EMPTY) continue;
  
          heatmap[y][x] = p.color;
          queue.insertBack(Fill(x, y, p.color));
        }
      }

      // 設置コスト低減のためにグラデーションがかかるようにする
      foreach(_; 0..25) {
        auto blured = heatmap.map!"a.dup".array;

        foreach(y; 0..L) foreach(x; 0..L) {
          if (stable[y][x]) continue;

          blured[y][x] *= 0;
          foreach(dx, dy; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
            auto ax = (x + dx + L) % L;
            auto ay = (y + dy + L) % L;
            blured[y][x] += heatmap[ay][ax];
          }
          blured[y][x] /= 4;
        }
        heatmap = blured.map!"a.dup".array;
      }
    }

    foreach(row; heatmap) {
      writefln("%(%s %)", row);
      stdout.flush();
    }

    auto measurementPartitions = [
      tuple( 36, 0.60),
      tuple( 64, 0.61),
      tuple(100, 0.82),
      tuple(169, 0.97),
      tuple(256, 0.98),
    ];

    real measurementThreashold = 0.60;
    foreach(m; measurementPartitions) {
      if (S < m[0]) break;
      measurementThreashold = max(measurementThreashold, m[1]);
    }
    measurementThreashold.deb;

    auto measureSize = min(S.to!real.sqrt.to!int * 2, 10);

    alias Assume = Tuple!(real, "score", int, "from", int, "to");
    auto assumes = new Assume[](0).heapify!"a.score > b.score";

    foreach(id; 0..N) {
      auto holeScore = new long[](N);
      auto measurement = new Measurement();
      foreach(creekId; 0..Game.instance.creekSize) {
        auto diff = bestCoords[creekId];
        foreach(t; 0..measureSize) {
          writefln("%(%s %)", [id, diff.y, diff.x]);
          stdout.flush();

          auto value = scan!int;
          auto m = measurement.add(creekId, value);
        }
      }
      auto scores = measurement.zAssume();
      foreach(to; 0..N) assumes.insert(Assume(scores[to], id, to));
    }

    writefln("%(%s %)", [-1, -1, -1]);
    stdout.flush();

    auto ans = new int[](N);
    bool[100] usedFrom, usedTo;
    foreach(assume; assumes) {
      if (usedFrom[assume.from] || usedTo[assume.to]) continue;

      usedFrom[assume.from] = usedTo[assume.to] = true;
      ans[assume.from] = assume.to;
    }
    ans.each!writeln;
    stdout.flush();
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
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

struct CombinationRange(T) {
  private {
    int combinationSize;
    int elementSize;
    int pointer;
    int[] cursor;
    T[] elements;
    T[] current;
  }

  public:

  this(T[] t, int combinationSize) {
    this.combinationSize = combinationSize;
    this.elementSize = cast(int)t.length;
    pointer = combinationSize - 1;
    cursor = new int[combinationSize];
    current = new T[combinationSize];
    elements = t.dup;
    foreach(i; 0..combinationSize) {
      cursor[i] = i;
      current[i] = elements[i];
    }
  }

  @property T[] front() {
    return current;
  }

  void popFront() {
    if (pointer == -1) return;

    if (cursor[pointer] == elementSize + pointer - combinationSize) {
      pointer--;
      popFront();
      if (pointer < 0) return;

      pointer++;
      cursor[pointer] = cursor[pointer - 1];
      current[pointer] = elements[cursor[pointer]];
    }

    cursor[pointer]++;
    current[pointer] = elements[cursor[pointer]];
  }

  bool empty() {
    return pointer == -1;
  }
}
CombinationRange!T combinations(T)(T[] t, int size) { return CombinationRange!T(t, size); }
