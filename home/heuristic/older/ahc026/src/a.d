import std.range;
void main() { runSolver(); }

// ---------------------------------------------

enum BOX_MAX = 200;

void problem() {
  int N = scan!int;
  int M = scan!int;
  int[][] B = scan!int(N).chunks(N / M).array;
  alias Location = Tuple!(int, "stackId", int, "index");
  int score = 10000;

  struct State {
    Location[] locations;
    DList!int[] stacks;
    int score, boxId;

    void move(int boxId, int to) {
      auto from = locations[boxId];
      // deb([boxId], from, to);

      if (to != 0) {
        foreach(b; stacks[to].array) locations[b].index += from.index;
        score -= from.index + 1;
      } 
      int [] tmp;
      foreach(i; 0..from.index) {
        auto b = stacks[from.stackId].front;
        stacks[from.stackId].removeFront;
        locations[b].stackId = to;
        tmp ~= b;
      }
      foreach_reverse(b; tmp) stacks[to].insertFront(b);
      foreach(b; stacks[from.stackId].array) locations[b].index -= from.index;
      // deb([boxId], from, to);
      // writefln("%s %s", boxId, to);
    }
  }

  auto solve() {
    Location[] locations = new Location[](N + 1);
    auto sizes = new int[](M + 1);
    auto stacks = (M + 1).iota.map!(m => DList!int()).array;
    foreach(m; 0..M) foreach_reverse(b; B[m]) {
      auto l = Location(m + 1, ++sizes[m + 1]);
      locations[b] = l;
      stacks[m + 1].insertBack(b);
    }

    State state = State(locations, stacks, score);

    void move(int boxId, int to) {
      auto from = locations[boxId];
      // deb([boxId], from, to);

      if (to != 0) {
        foreach(b; stacks[to].array) locations[b].index += from.index;
        score -= from.index + 1;
      } 
      int [] tmp;
      foreach(i; 0..from.index) {
        auto b = stacks[from.stackId].front;
        stacks[from.stackId].removeFront;
        locations[b].stackId = to;
        tmp ~= b;
      }
      foreach_reverse(b; tmp) stacks[to].insertFront(b);
      foreach(b; stacks[from.stackId].array) locations[b].index -= from.index;
      // deb([boxId], from, to);
      writefln("%s %s", boxId, to);
    }

    int boxId = 1;
    while(boxId <= N) {
      auto loc = locations[boxId];
      bool[int] neighbors;
      foreach(b; boxId..min(N + 1, boxId + 5)) {
        neighbors[locations[b].stackId] = true;
      }

      while (loc.index != 1) {
        int[] arr = stacks[loc.stackId].array[0..loc.index - 1];

        if (loc.index <= 10) {
          int pre = arr[0];
          foreach(i, a; arr[1..$]) {
            if (pre > a) {
              arr = arr[0..i + 1];
              break;
            }
            pre = a;
          }
        }

        auto target = arr[$ - 1];
        int best;
        real bestScore = 2.0L.pow(200);
        foreach(t; iota(1, M + 1).filter!(m => !(m in neighbors))) {
          real testScore = 0;
          foreach(s; stacks[t].array) {
            testScore += arr.map!(a => max(0, a - s).to!real.pow(11)).sum;
          }
          if (bestScore.chmin(testScore)) best = t;
        }
        move(target, best);
        loc = locations[boxId];
      }

      move(boxId, 0);
      boxId++;
    }

    stderr.writefln("Score = %s", score);
  }

  solve();
}

// ----------------------------------------------

import std;
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
