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
  bool[][] G = scan!string(N).map!(s => s.map!(c => c == '#').array).array;

  bool blocked(int nr, int nc) {
    return min(nr, nc) < 0 || max(nr, nc) >= N || G[nr][nc];
  }

  real[][] calcProb(real[][] p) {
    real[][] ret = new real[][](N, N);
    foreach(r; 0..N) foreach(c; 0..N) {
      ret[r][c] = G[r][c] ? int.max : 0;
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
  

  // int[][] aroundWalls = new int[][](N, N);
  int aroundWall(int r, int c) {
    int ret = 4;
    foreach(dr, dc; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
      auto nr = r + dr;
      auto nc = c + dc;
      if (blocked(nr, nc)) continue;

      ret--;
    }
    return ret;
  }

  real[][] prob = new real[][](N, N); {
    foreach(r; 0..N) foreach(c; 0..N) {
      prob[r][c] = G[r][c] ? int.max : 1.0L / (N^^2 - M);
    }
    prob = calcProb(prob);
  }

  prob.each!deb;
  
  int rest = N^^2 - M;
  void block(int r, int c) {
    G[r][c] = true;
    writefln("%s %s", r, c);
    rest--;
    prob = calcProb(prob);
  }

  foreach(r; 0..N) foreach(c; 0..N) {
    if (blocked(r, c)) continue;

    if (aroundWall(r, c) == 0) {
      block(r, c);
    }
  }

  calcProb(prob).each!deb;

  while(rest > 0) {
    int minR, minC;
    real minProb = int.max;

    foreach(r; 0..N) foreach(c; 0..N) {
      if (blocked(r, c)) continue;

      if (minProb.chmin(prob[r][c])) {
        minR = r;
        minC = c;
      }
    }
    block(minR, minC);
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
