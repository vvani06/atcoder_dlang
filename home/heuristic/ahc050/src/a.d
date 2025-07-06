void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int M = scan!int;
  bool[][] GRID = scan!string(N).map!(s => s.map!(c => c == '#').array).array;

  alias Coord = Tuple!(int, "r", int, "c");

  final class State {
    bool[][] G;
    int rest;
    float[][] prob;
    Coord[] ans;
    float score = 0;
    float liveProb = 1;

    this(bool[][] grid) {
      G = grid.map!"a.dup".array;
      rest = N^^2 - grid.map!(g => g.count(true)).sum.to!int;

      prob = new float[][](N, N);
      foreach(r; 0..N) foreach(c; 0..N) {
        prob[r][c] = G[r][c] ? float.max / 100 : 1.0L / (N^^2 - M);
      }
      prob = calcProb(prob);
    }

    bool blocked(int nr, int nc) {
      return min(nr, nc) < 0 || max(nr, nc) >= N || G[nr][nc];
    }

    float[][] calcProb(float[][] p) {
      float[][] ret = new float[][](N, N);
      foreach(r; 0..N) foreach(c; 0..N) {
        ret[r][c] = G[r][c] ? float.max / 100 : 0;
      }

      foreach(r; 0..N) foreach(c; 0..N) {
        if (blocked(r, c)) continue;
        
        foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
          auto nr = r;
          auto nc = c;
          while(!blocked(nr + dr, nc + dc)) {
            nr += dr;
            nc += dc;
          }
          ret[nr][nc] += p[r][c] / 4;
        }
      }
      return ret;
    }

    int countAroundWall(int r, int c) {
      int ret = 4;
      foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
        auto nr = r + dr;
        auto nc = c + dc;
        if (blocked(nr, nc)) continue;

        ret--;
      }
      return ret;
    }
    
    void block(int r, int c) {
      G[r][c] = true;
      ans ~= Coord(r, c);
      rest--;
      
      liveProb -= prob[r][c];
      score += liveProb;

      prob = calcProb(prob);
    }

    void outputAsAns() {
      foreach(a; ans) {
        writefln("%s %s", a[0], a[1]);
      }
    }
  }

  State bestState = new State(GRID);
  
  Coord[] safeCoords; {
    auto state = new State(GRID);
    foreach(r; 0..N) foreach(c; 0..N) {
      if (state.blocked(r, c)) continue;

      if (state.countAroundWall(r, c) == 0) {
        state.block(r, c);
      }
    }
    safeCoords = state.ans.dup;
  }

  while(!elapsed(1800)) {
    auto state = new State(GRID);

    int distC(Coord coord) {
      return abs(coord.r - N/2) + abs(coord.c - N/2);
    }

    bool distCmp(Coord a, Coord b) {
      return distC(a) > distC(b);
    }

    // safeCoords.sort!distCmp;
    safeCoords.randomShuffle(RND);
    foreach(coord; safeCoords) {
      state.block(coord.r, coord.c);
    }
    

    while(state.rest > 0) {
      int minR, minC;
      float minProb = float.max / 100;

      foreach(r; 0..N) foreach(c; 0..N) {
        if (state.blocked(r, c)) continue;

        if (minProb.chmin(state.prob[r][c])) {
          minR = r;
          minC = c;
        }
      }
      state.block(minR, minC);
    }

    if (bestState.score < state.score) {
      bestState = state;
    }
  }

  bestState.outputAsAns();
  (bestState.score * 1_000_000 / (N^^2 - M - 1)).deb;
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
