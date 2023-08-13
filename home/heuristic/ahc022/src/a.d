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

    int maxColor = min(1000, (S * N * 3).to!int);

    isHole = new bool[][](L, L);
    foreach(c; P) isHole[c.y][c.x] = true;
    aroundCoords = availableAroundCoords();
    
    sampleSize = max(2, min(N, maxColor / S / 3));
    while(sampleSize^^creekSize < N && creekSize < aroundCoords.length) creekSize++;

    if (sampleSize^^creekSize < N) {
      creekSize = aroundCoords.length.to!int;
      while(sampleSize^^creekSize < N) sampleSize++;
    }

    while ((sampleSize - 1)^^creekSize >= N) sampleSize--;
    sampleStep = maxColor / (sampleSize - 1);
    samples = iota(0, maxColor + 1, sampleStep).array;

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
    auto AROUND_SIZE = L / 2;
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
    auto coords = badCount.keys.filter!(a => badCount[a] <= 0).array.multiSort!(
      (a, b) => badCount[a] < badCount[b],
      (a, b) => abs(a.x) + abs(a.y) < abs(b.x) + abs(b.y),
    );
    coords.deb;
    coords.map!(a => [badCount[a]]).deb;
    return coords.array[0..min($, 7)];
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
    if (measured[creekId].length < 5) return 0;

    const creekSize = Game.instance.creekSize;
    const sampleSize = Game.instance.sampleSize;
    const samples = Game.instance.samples;

    auto scores = new long[](sampleSize);
    foreach(m; measured[creekId]) {
      foreach(s; 0..sampleSize) {
        scores[s] += abs(samples[s] - m)^^2;
      }
    }

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
  Game.instance = Game(L, N, S, P);
  
  auto RND = Xorshift(unpredictableSeed);

  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

  enum P_EMPTY = -1;
  enum MEASURE_TIMES_MAX = 10000;
  enum MEASURE_TIMES_EACH_MAX = 100;

  auto solve() {
    Hole[] holes; foreach(i, p; P) {
      holes ~= Hole(i.to!int, p);
      holes[$ - 1].deb;
      holes[$ - 1].asCreek.deb;
    }

    auto heatmap = new int[][](L, L); {
      auto stable = new bool[][](L, L);
      foreach(ref h; heatmap) h[] = P_EMPTY;
      auto arounds = Game.instance.aroundCoords;

      alias Fill = Tuple!(int, "x", int, "y", int, "color");
      auto queue = DList!Fill();
      foreach(h; holes) {
        auto creeks = h.asCreek;
        foreach(i; 0..Game.instance.creekSize) {
          auto d = arounds[i];
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
      foreach(_; 0..100) {
        auto blured = heatmap.map!"a.dup".array;

        foreach(y; 0..L) foreach(x; 0..L) {
          if (stable[y][x]) continue;

          blured[y][x] *= 1;
          foreach(dx, dy; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
            auto ax = (x + dx + L) % L;
            auto ay = (y + dy + L) % L;
            blured[y][x] += heatmap[ay][ax];
          }
          blured[y][x] /= 5;
        }
        heatmap = blured.map!"a.dup".array;
      }
    }

    foreach(row; heatmap) {
      writefln("%(%s %)", row);
      stdout.flush();
    }

    auto ans = new int[](N);
    auto measureSize = MEASURE_TIMES_MAX / N / Game.instance.creekSize;
    foreach(id; 0..N) {
      auto holeScore = new long[](N);
      auto measurement = new Measurement();
      foreach(creekId; 0..Game.instance.creekSize) {
        auto diff = Game.instance.aroundCoords[creekId];
        foreach(t; 0..measureSize) {
          writefln("%(%s %)", [id, diff.y, diff.x]);
          stdout.flush();

          auto value = scan!int;
          auto m = measurement.add(creekId, value);
          m.deb;
          if (m >= 0.66) break;
        }
      }
      id.deb;
      ans[id] = measurement.assume;
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
