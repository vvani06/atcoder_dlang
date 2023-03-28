void main() { runSolver(); }

// ----------------------------------------------

enum MAX_D = 14;
enum SIZE_MAX = 400;
enum MAX_SIZE_ID = 50000;
enum MAX_TIME_MS = 5750;
enum ROTATES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 24, 25, 26, 27];
alias MATRIX = int[MAX_D][MAX_D][MAX_D];
// alias MATRIX = int[][][];

void problem() {
  auto D = scan!int;
  auto Diota = D.iota.array;
  auto XYZ = cartesianProduct(Diota, Diota, Diota);
  auto F1 = scan!string(D).map!(s => s.map!"a == '1'".array).array;
  auto R1 = scan!string(D).map!(s => s.map!"a == '1'".array).array;
  auto F2 = scan!string(D).map!(s => s.map!"a == '1'".array).array;
  auto R2 = scan!string(D).map!(s => s.map!"a == '1'".array).array;
  auto F = [F1, F2];
  auto R = [R1, R2];
  auto MAX_MERGE = D * 2;

  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

  struct Coord {
    int x, y, z;

    Coord add(Coord other) {
      return Coord(x + other.x, y + other.y, z + other.z);
    }
    Coord sub(Coord other) {
      return Coord(x - other.x, y - other.y, z - other.z);
    }
    Coord rotate(int axis, int step) {
      step %= 4;
      if (step == 0) return this;

      if (axis == 0) {
        if (step == 1) return Coord(x, z, -y);
        if (step == 2) return Coord(x, -y, -z);
        if (step == 3) return Coord(x, -z, y);
      }
      if (axis == 1) {
        if (step == 1) return Coord(-z, y, x);
        if (step == 2) return Coord(-x, y, -z);
        if (step == 3) return Coord(z, y, -x);
      }
      if (axis == 2) {
        if (step == 1) return Coord(y, -x, z);
        if (step == 2) return Coord(-x, -y, z);
        if (step == 3) return Coord(-y, x, z);
      }
      return Coord(-1, -1, -1);
    }
    Coord rotate(int i) {
      auto ret = this;
      foreach(j; 0..3) {
        if (i > 0) {
          ret = ret.rotate(j, i % 4);
          i /= 4;
        }
      }
      return ret;
    }

    int min() { return std.algorithm.comparison.min(x, y, z); }
    int max() { return std.algorithm.comparison.max(x, y, z); }
    bool valid() { return min >= 0 && max < D; }

    int of(MATRIX matrix) { return matrix[x][z][y]; }
    int set(ref MATRIX matrix, int value) { return matrix[x][z][y] = value; }

    enum AX = Coord(1, 0, 0);
    enum AY = Coord(0, 1, 0);
    enum AZ = Coord(0, 0, 1);
    enum BX = Coord(-1, 0, 0);
    enum BY = Coord(0, -1, 0);
    enum BZ = Coord(0, 0, -1);
    enum MOVES = [AX, AY, AZ, BX, BY, BZ];
  }

  class Requirement {
    bool[MAX_D][MAX_D][2] front, right;
    int[MAX_D][MAX_D][2] fv, rv;
    int[MAX_D][MAX_D][2] fc, rc;

    MATRIX[2] initMatrix;
    int[MAX_SIZE_ID] size;
    int maxId;

    this(bool[][][] f, bool[][][] r) {
      size[0] = 10000;

      foreach(i; 0..2) {
        foreach(x, y, z; XYZ) {
          if (!f[i][y][x] || !r[i][y][z]) continue;

          front[i][x][y] = right[i][z][y] = true;
          fc[i][x][y]++;
          rc[i][z][y]++;

          initMatrix[i][x][z][y] = MAX_SIZE_ID;
          // size[maxId] = 1;
        }

        foreach(y; 0..D) foreach(t; 0..D) {
          if (fc[i][t][y] > 0) fv[i][t][y] = 1 + D - fc[i][t][y];
          if (rc[i][t][y] > 0) rv[i][t][y] = 1 + D - rc[i][t][y];
        }
      }
    }
  }

  struct State {
    Requirement r;
    MATRIX[2] v;
    int[MAX_SIZE_ID] size;
    int vid;
    int[MAX_D][MAX_D][2] fc, rc;
    int[MAX_D][MAX_D][2] fv, rv;
    bool[Coord][2] coords;
    bool[int] blocks;

    this(Requirement r) {
      this.r = r;
      this.v = r.initMatrix;
      this.size = r.size;
      this.vid = r.maxId;
      this.fc = r.fc;
      this.rc = r.rc;
      this.fv = r.fv;
      this.rv = r.rv;

      foreach(i; 0..2) {
        foreach(x, y, z; XYZ) {
          if (at(i, x, y, z) > 0) {
            coords[i][Coord(x, y, z)] = true;
          }
        }
      }
    }

    this(State s) {
      this.r = s.r;
      this.v = s.v.dup;
      this.size = s.size.dup;
      this.vid = s.vid;
      this.fc = s.fc.dup;
      this.rc = s.rc.dup;
      this.fv = s.fv.dup;
      this.rv = s.rv.dup;
      this.coords = s.coords.dup;
      this.blocks = s.blocks.dup;
    }

    void update(int i, int x, int y, int z, int to) {
      const from = at(i, x, y, z);
      if (from > 0 && from < MAX_SIZE_ID && (to == 0 || to == MAX_SIZE_ID)) {
        coords[i][Coord(x, y, z)] = true;
        fv[i][x][y]++;
        rv[i][z][y]++;
      }
      if ((from == 0 || from == MAX_SIZE_ID) && to > 0 && to < MAX_SIZE_ID) {
        coords[i].remove(Coord(x, y, z));
        fv[i][x][y]--;
        rv[i][z][y]--;
      }

      v[i][x][z][y] = to;
    }
    void update(int i, Coord c, int value) { return update(i, c.x, c.y, c.z, value); }

    int at(int i, int x, int y, int z) {
      return v[i][x][z][y];
    }
    int at(int i, Coord c) { return at(i, c.x, c.y, c.z); }

    int sizeOf(int i) {
      if (i == 0) return 10000;
      if (i >= MAX_SIZE_ID) return 1;
      return size[i];
    }
    int sizeOf(int i, Coord c) {
      return sizeOf(c.of(v[i]));
    }

    void trim() {
      int[2] sizes;
      foreach(x, y, z; XYZ) {
        if (at(0, x, y, z) != 0) sizes[0]++;
        if (at(1, x, y, z) != 0) sizes[1]++;
      }
      
      while(sizes[0] != sizes[1]) {
        foreach(i; 0..2) {
          if (sizes[0] == sizes[1]) continue;
          if (i == 0 && sizes[0] < sizes[1]) continue;
          if (i == 1 && sizes[0] > sizes[1]) continue;

          foreach(c; coords[i].keys.randomShuffle) {
            const x = c.x, y = c.y, z = c.z;
            if (fc[i][x][y] == 1 || rc[i][z][y] == 1) continue;

            fc[i][x][y]--;
            rc[i][z][y]--;
            update(i, c, 0);
            sizes[i]--;
            break;
          }
        }
      }
    }

    void destroy(int block) {
      if (!(block in blocks)) return;

      blocks.remove(block);
      size[block] = 0;
      foreach(i; 0..2) foreach(x, y, z; XYZ) {
        if (at(i, x, y, z) == block) update(i, x, y, z, MAX_SIZE_ID);
      }
    }

    int merge(Coord from1, Coord from2, int rot, bool dryrun) {
      if (sizeOf(0, from1) != 1 || sizeOf(1, from2) != 1) return 0;

      MATRIX visited;
      MATRIX queued;
      from1.set(visited, 1);
      from1.set(queued, 1);
      const base = dryrun ? from1.of(v[0]) : ++vid;

      if (!dryrun) {
        update(0, from1, base);
        update(1, from2, base);
        blocks[base] = true;
        size[base] = 1;
      }

      int merged, score;
      DList!Coord queue;
      foreach(d; Coord.MOVES) {
        auto next = from1.add(d);
        if (next.valid) {
          queue.insertBack(next);
          next.set(queued, 1);
        }
      }

      while(!queue.empty) {
        auto cur = queue.front; queue.removeFront;

        if (cur.of(visited) || !cur.valid) continue;
        cur.set(visited, 1);

        auto diff = cur.sub(from1).rotate(rot);
        auto cur2 = from2.add(diff);
        if (!cur2.valid) continue;

        // 体積1のブロックだけを侵食する
        if (sizeOf(0, cur) != 1) continue;
        if (sizeOf(1, cur2) != 1) continue;

        // [cur, cur2].deb;
        // [cur.of(v[0]), cur2.of(v[1])].deb;

        // ブロックのマージ
        if (!dryrun) {
          foreach(i, c; [cur, cur2].enumerate(0)) {
            update(i, c, base);
          }
          size[base]++;
        }
        merged++;
        score += fv[0][cur.x][cur.y] + rv[0][cur.z][cur.y];
        score += fv[1][cur.x][cur.y] + rv[1][cur.z][cur.y];
        // score++;
        if (merged >= MAX_MERGE) break;

        foreach(d; Coord.MOVES) {
          auto next = cur.add(d);
          if (next.valid && !next.of(visited) && !next.of(queued)) {
            next.set(queued, 1);
            queue.insertBack(next);
          }
        }
      }

      return score * merged;
    }

    void clean() {
      foreach(i; 0..2) {
        auto cf = new int[][](D, D);
        auto cr = new int[][](D, D);

        foreach(x, y, z; XYZ) {
          if (v[i][x][z][y] == 0) continue;

          cf[x][y]++;
          cr[z][y]++;
        }

        foreach(x, y, z; XYZ) {
          if (sizeOf(v[i][x][z][y]) == 1 && cf[x][y] > 1 && cr[z][y] > 1) {
            update(i, Coord(x, y, z), 0);
            cf[x][y]--;
            cr[z][y]--;
          }
        }
      }

      auto singles = new Coord[][](2, 0);
      foreach(i; 0..2) {
        foreach(x, y, z; XYZ) {
          if (sizeOf(v[i][x][z][y]) == 1) singles[i] ~= Coord(x, y, z);
        }
      }
      foreach(a, b; zip(singles[0], singles[1])) {
        update(0, a, ++vid);
        update(1, b, vid);
        size[vid] = 1;
      }
    }

    long score() {
      int[int] colors;
      long ans;
      foreach(x, y, z; XYZ) {
        if (v[0][x][y][z] >= MAX_SIZE_ID) ans += 10L^^9; else colors[v[0][x][y][z]] = size[v[0][x][y][z]];
        if (v[1][x][y][z] >= MAX_SIZE_ID) ans += 10L^^9; else colors[v[1][x][y][z]] = size[v[1][x][y][z]];
      }
      colors.remove(0);
      ans += colors.values.map!"10L^^9 / a".sum;
      return ans;
    }

    long tryScore() {
      auto test = State(this);
      test.clean;
      return test.score;
    }

    string toString() {
      string[] ret;

      int[int] conv; {
        auto using = new int[](0);
        int t;
        foreach(i; 0..2) foreach(x, y, z; XYZ) {
          if (v[i][x][z][y] == MAX_SIZE_ID) v[i][x][z][y] += ++t;
          using ~= v[i][x][z][y];
        }
        auto uni = using.sort.uniq;
        foreach(u; uni.enumerate(0)) conv[u[1]] = u[0];
      }

      ret ~= (conv.length - 1).to!string;
      foreach(i; 0..2) {
        foreach(x; 0..D) {
          int[] arr;
          foreach(z; 0..D) foreach(y; 0..D) arr ~= conv[v[i][x][z][y]];
          ret ~= "%(%03d %)".format(arr);
        }
      }
      return ret.joiner("\n").to!string;
    }
  }

  auto solve() {
    auto requirement = new Requirement(F, R);
    auto bestState = State(requirement);
    long bestScore = long.max;
    
    int tried;
    while(true) {
      if (elapsed(MAX_TIME_MS)) break;

      auto state = State(requirement);
      if (tried % 2) state.trim;

      int badCount;
      while(true) {
        if (elapsed(MAX_TIME_MS)) break;
        
        auto cs1 = state.coords[0].keys.randomShuffle[0..min(($ + 5) / 6, 64)];
        auto cs2 = state.coords[1].keys.randomShuffle[0..min(($ + 5) / 6, 64)];

        int best, bestRot;
        Coord bestFrom, bestTo;

        foreach(from, to; zip(cs1, cs2)) {
          foreach(rot; ROTATES) {
            auto merged = state.merge(from, to, rot, true);
            if (best.chmax(merged)) {
              bestFrom = from;
              bestTo = to;
              bestRot = rot;
            }
          }
        }
          
        if (best > 0) {
          state.merge(bestFrom, bestTo, bestRot, false);
          badCount = 0;
        } else {
          badCount++;
        }

        if (badCount >= 3) {
          auto tryScore = state.tryScore;
          if (bestScore > tryScore) {
            tryScore.deb;
            bestScore = tryScore;
            bestState = State(state);
          } else {
            state = State(bestState);
          }
          foreach(i; 0..2) {
            if (!state.blocks.empty) state.destroy(state.blocks.keys.choice);
          }
          tried++;
          badCount = 0;
          // break;
        }
      }
    }

    tried.deb;
    bestState.clean;
    bestState.score.deb;
    bestState.writeln;
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
  enum BORDER = "#==================================";
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; break; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
