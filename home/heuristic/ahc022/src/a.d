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
  int dense;

  enum DENSE_BORDER = 3;

  int measurementMode() {
    if (dense == 0) return 0;
    if (dense < DENSE_BORDER && creekSize <= 2) return 0;
    return 1;
  }

  this(int l, int n, int s, Coord[] p) {
    L = l;
    N = n;
    S = s;
    P = p;
    
    sampleSize = max(2, min(N, 1200 / S));
    while(sampleSize^^creekSize < N) creekSize++;
    while ((sampleSize - 1)^^creekSize >= N) sampleSize--;

    int maxColor = min(1000, (S * sampleSize * 2).to!int);
    sampleStep = maxColor / (sampleSize - 1);
    samples = iota(0, maxColor + 1, sampleStep).array;

    int[] odds, evens;
    foreach(i; 0..sampleSize) {
      if (i % 2 == 0) odds ~= samples[i]; else evens ~= samples[i];
    }
    samples = odds ~ evens.reverse.array;

    [creekSize, sampleSize, sampleStep].deb;
    samples.deb;

    isHole = new bool[][](L, L);
    foreach(c; P) isHole[c.y][c.x] = true;
    aroundCoords = availableAroundCoords(L / 2);
    if (measurementMode() == 1) aroundCoords = availableAroundCoords(1);
    dense.deb;
  }

  int[] asCreek(int id) {
    int[] ret = new int[](creekSize);
    foreach(i; 0..creekSize) {
      ret[i] = id % sampleSize;
      id /= sampleSize;
    }
    return ret.reverse.array;
  }

  Coord[] availableAroundCoords(int aroundSize) {
    int[Coord] badCount;
    foreach(dy; -aroundSize..aroundSize + 1) foreach(dx; -aroundSize..aroundSize + 1) badCount[Coord(dx, dy)] = 0;

    foreach(c; P) {
      foreach(dy; -aroundSize..aroundSize + 1) foreach(dx; -aroundSize..aroundSize + 1) {
        auto y = (c.y + dy + L) % L;
        auto x = (c.x + dx + L) % L;
        if (isHole[y][x]) badCount[Coord(dx, dy)]++;
      }
    }

    badCount[Coord(0, 0)] = -1;
    auto coords = badCount.keys.array.multiSort!(
      (a, b) => badCount[a] < badCount[b],
      (a, b) => abs(a.x) + abs(a.y) < abs(b.x) + abs(b.y),
    );
    coords.deb;
    coords.map!(a => [badCount[a]]).deb;
    if (aroundSize > 1) dense = badCount[coords[1]] * (creekSize - 1);
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
    value = min(value, Game.instance.samples.maxElement);
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
  auto RND = Xorshift(unpredictableSeed);
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

  Game.instance = Game(L, N, S, P);

  enum P_EMPTY = -1;
  enum MEASURE_TIMES_MAX = 10000;

  auto solve() {
    Hole[] holes; foreach(i, p; P) {
      holes ~= Hole(i.to!int, p);
    }

    Coord[] bestCoords = Game.instance.aroundCoords[0..1];
    auto heatmap = new int[][](L, L); {
      int best = int.max;
      foreach(comb; Game.instance.aroundCoords[1..$].combinations(Game.instance.creekSize - 1)) {
        int conflicts;
        comb = Game.instance.aroundCoords[0] ~ comb;
        auto used = new int[][](L, L);
        foreach(ref u; used) u[] = P_EMPTY;
        foreach(h; holes) {
          auto creeks = h.asCreek;

          bool conflicted;
          foreach(i; 0..Game.instance.creekSize) {
            auto d = comb[i];
            auto x = (h.coord.x + d.x + L) % L;
            auto y = (h.coord.y + d.y + L) % L;
            if (used[y][x] != P_EMPTY && used[y][x] != Game.instance.samples[creeks[i]]) {
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
            used[y][x] = Game.instance.samples[creeks[i]];
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
          if (heatmap[y][x] != P_EMPTY && heatmap[y][x] != Game.instance.samples[creeks[i]]) {
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

    auto ans = new int[](N);
    if (Game.instance.measurementMode() == 0) {
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

      auto measureSize = MEASURE_TIMES_MAX / N / Game.instance.creekSize;
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
            m.deb;
            if (m >= measurementThreashold) break;
          }
        }
        id.deb;
        ans[id] = measurement.assume;
      }
    } else {
      Coord[] arounds;
      foreach(y; -1..2) foreach(x; -1..2) arounds ~= Coord(x, y);

      auto expected = new real[][](N, arounds.length);
      foreach(hole; holes) {
        foreach(i, a; arounds) {
          auto ax = (hole.coord.x + a.x + L) % L;
          auto ay = (hole.coord.y + a.y + L) % L;
          [ax, ay].deb;
          expected[hole.id][i] = heatmap[ay][ax];
        }
      }

      auto testTimes = 8;
      auto measured = new real[][](N, arounds.length);
      foreach(id; 0..N) {
        foreach(i, a; arounds) {
          auto values = new int[](0);
          foreach(_; 0..testTimes) {
            writefln("%(%s %)", [id, a.y, a.x]);
            stdout.flush();
            auto value = scan!int;
            values ~= value;
          }
          measured[id][i] = values.mean;
        }
        measured[id].deb;
      }

      alias Queue = Tuple!(real, "score", int, "from", int, "to");
      auto queue = new Queue[](0).heapify!"a.score > b.score";
      foreach(from; 0..N) foreach(to; 0..N) {
        real score = 0;
        foreach(i; 0..arounds.length) {
          score += (expected[from][i] - measured[to][i]).pow(2);
        }
        queue.insert(Queue(score, from, to));
      }

      bool[100] usedFrom, usedTo;
      while(!queue.empty) {
        auto m = queue.front; queue.removeFront;
        if (usedFrom[m.from] || usedTo[m.to]) continue;

        m.deb;
        ans[m.to] = m.from;
        usedFrom[m.from] = usedTo[m.to] = true;
      }
    }
    
    writefln("%(%s %)", [-1, -1, -1]);
    stdout.flush();
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
