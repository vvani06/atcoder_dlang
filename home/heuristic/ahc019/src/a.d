void main() { runSolver(); }

// ----------------------------------------------

enum MAX_D = 14;
enum SIZE_MAX = 32;
enum ROTATES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 24, 25, 26, 27];
alias MATRIX = int[MAX_D][MAX_D][MAX_D];
// alias MATRIX = int[][][];

void problem() {
  auto D = scan!int;
  auto Diota = D.iota;
  auto XYZ = cartesianProduct(Diota, Diota, Diota);
  auto F1 = scan!string(D).map!(s => s.map!"a == '1'".array).array;
  auto R1 = scan!string(D).map!(s => s.map!"a == '1'".array).array;
  auto F2 = scan!string(D).map!(s => s.map!"a == '1'".array).array;
  auto R2 = scan!string(D).map!(s => s.map!"a == '1'".array).array;
  auto F = [F1, F2];
  auto R = [R1, R2];

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

  struct State {
   MATRIX[2] v;
   int[5000] size;
   int vid;

    void update(int i, Coord c, int value) {
      v[i][c.x][c.z][c.y] = value;
    }

    this(int d) {
      // v = new int[][][][](2, d, d, d);

      size[0] = 5000;
      foreach(i; 0..2) {
        foreach(x, y, z; XYZ) {
          if (!F[i][y][x] || !R[i][y][z]) continue;

          v[i][x][z][y] = ++vid;
          size[vid] = 1;
        }
      }
    }

    int merge(Coord from1, Coord from2, int rot, bool dryrun) {
      if (size[from1.of(v[0])] != 1 || size[from2.of(v[1])] != 1) return 0;

      MATRIX visited;
      MATRIX queued;
      from1.set(visited, 1);
      from1.set(queued, 1);
      const base = from1.of(v[0]);

      if (!dryrun) update(1, from2, base);

      int merged;
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
        if (size[cur.of(v[0])] != 1) continue;
        if (size[cur2.of(v[1])] != 1) continue;

        // [cur, cur2].deb;
        // [cur.of(v[0]), cur2.of(v[1])].deb;

        // ブロックのマージ
        if (!dryrun) {
          update(0, cur, base);
          update(1, cur2, base);
          size[base]++;
        }
        merged++;
        if (merged >= SIZE_MAX) return merged;

        foreach(d; Coord.MOVES) {
          auto next = cur.add(d);
          if (next.valid && !next.of(visited) && !next.of(queued)) {
            next.set(queued, 1);
            queue.insertBack(next);
          }
        }
      }

      return merged;
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
          if (size[v[i][x][z][y]] == 1 && cf[x][y] > 1 && cr[z][y] > 1) {
            update(i, Coord(x, y, z), 0);
            cf[x][y]--;
            cr[z][y]--;
          }
        }
      }
    }

    string toString() {
      string[] ret;

      int[int] conv; {
        auto using = new int[](0);
        foreach(i; 0..2) foreach(x, y, z; XYZ) {
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

    long score() {
      int[int] colors;
      foreach(x, y, z; XYZ) {
        colors[v[0][x][y][z]] = size[v[0][x][y][z]];
        colors[v[1][x][y][z]] = size[v[1][x][y][z]];
      }
      colors.remove(0);
      return colors.values.map!"10L^^9 / a".sum;
    }
  }

  auto solve() {
    auto bestState = State(D);

    int tried;
    while(true) {
      if (elapsed(5000)) break;

      auto state = State(D);
      auto coords1 = XYZ.array.redBlackTree;
      auto coords2 = XYZ.array.redBlackTree;

      int badCount;
      while(true) {
        if (elapsed(5000)) break;
        
        auto cs1 = coords1.array.randomShuffle[0..min($, D^^3 / 4 , 256)];
        auto cs2 = coords2.array.randomShuffle[0..min($, D^^3 / 4 , 256)];

        foreach(c1; cs1) {
          auto from = Coord(c1[0], c1[1], c1[2]);
          Coord bestCoord;
          int best, bestRot;
          foreach(c2; cs2) {
            auto to = Coord(c2[0], c2[1], c2[2]);
            foreach(rot; ROTATES) {
              auto merged = state.merge(from, to, rot, true);
              if (best.chmax(merged)) {
                bestCoord = to;
                bestRot = rot;
              }
            }
            if (best >= SIZE_MAX) break;
          }
          
          if (best > 0) {
            // best.deb;
            state.merge(from, bestCoord, bestRot, false);
            auto base = bestCoord.of(state.v[0]);

            foreach(x, y, z; XYZ) {
              auto coord = Coord(x, y, z);
              if (coord.of(state.v[0]) == base) {
                coords1.removeKey(tuple(x, y, z));
              }
              if (coord.of(state.v[1]) == base) {
                coords2.removeKey(tuple(x, y, z));
              }
            }
          } else {
            badCount++;
          }
        }

        if (badCount >= 5) break;
      }

      state.clean;
      if (bestState.score > state.score) bestState = state;
      (++tried).deb;
    }

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
