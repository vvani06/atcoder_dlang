import std.range;
void main() { runSolver(); }

// ---------------------------------------------

enum BOX_MAX = 200;

// class Box {
//   int id;
//   Box parent, child;

//   this(int id, Box parent, Box child) {
//     this.id = id;
//     this.parent = parent;
//     this.parent = parent;
//   }

//   bool isBase() { return id >= BOX_MAX; }
//   int stackId() {
//     Box cur = this;
//     while(!cur.isBase) cur = parent;
//     return cur.id - BOX_MAX;
//   }
// }

void problem() {
  int N = scan!int;
  int M = scan!int;
  int[][] B = scan!int(N).chunks(N / M).array;
  alias Location = Tuple!(int, "stackId", int, "index");
  int score = 10000;

  auto solve() {
    Location[] locations = new Location[](N + 1);
    auto sizes = new int[](M + 1);
    auto stacks = (M + 1).iota.map!(m => new DList!int()).array;
    foreach(m; 0..M) foreach_reverse(b; B[m]) {
      auto l = Location(m + 1, ++sizes[m + 1]);
      locations[b] = l;
      stacks[m + 1].insertBack(b);
    }

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

    foreach(boxId; 1..N + 1) {
      auto loc = locations[boxId];

      if (loc.index != 1) {
        int[] arr = stacks[loc.stackId].array[0..loc.index - 1];
        int[][] subsets;

        if (loc.index <= 2) {
          subsets ~= [arr[0]];
          int pre = arr[0];
          foreach(a; arr[1..$]) {
            if (pre > a) {
              subsets[$ - 1] ~= a;
            } else {
              subsets ~= [a];
            }
            pre = a;
          }
        } else {
          subsets ~= arr;
        }

        bool[int] neighbors;
        foreach(b; boxId..min(N + 1, boxId + 5)) {
          neighbors[locations[b].stackId] = true;
        }

        // subsets.deb;
        // foreach(subset; arr.chunks(arr.length.to!real.pow(1).to!int + 1)) {
        foreach(subset; subsets) {
          auto target = subset[$ - 1];
          int best;
          real bestScore = 2.0L.pow(200);
          foreach(t; iota(1, M + 1).filter!(m => !(m in neighbors))) {
            real testScore = 0;
            foreach(s; stacks[t].array) {
              testScore += subset.map!(a => max(0, a - s).to!real.pow(11)).sum;
            }
            if (bestScore.chmin(testScore)) best = t;
          }
          move(target, best);
        }
      }
      move(boxId, 0);
      // stacks.map!"a.array".each!deb;
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
