void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  int W = scan!int;
  int D = scan!int;
  int N = scan!int;
  int[][] A = scan!int(D * N).chunks(N).array;

  struct Rect {
    int l, t, r, b;

    string toString() {
      return "%(%d %)".format([l, t, r, b]);
    }
  }

  auto solve() {
    auto maximums = N.iota.map!(i => A.map!(a => a[i]).maxElement).array;
    maximums.deb;

    A.map!(a => (W^^2 - a.sum)*10000L / W^^2).deb;

    foreach(segs; A) {
      Rect[] ans = new Rect[](N);

      int preRow;
      int curLarge = N - 1;
      int curSmall = 0;
      
      while(curLarge >= curSmall) {
        int waste = int.max;
        int bestSmall, bestRowSize = W - preRow;
        foreach(small; 0..min(5, curLarge - curSmall)) {
          int seg = segs[curLarge];
          foreach(i; curSmall..curSmall + small) seg += segs[i];

          int rowSize = (seg + W - 1) / W;
          if (waste.chmin(rowSize * W - seg)) {
            bestSmall = small;
            bestRowSize = rowSize;
          }
        }

        [bestSmall, bestRowSize].deb;
        int preColumn;
        foreach(s; curSmall..curSmall + bestSmall) {
          int columnSize = (segs[s] + bestRowSize - 1) / bestRowSize;
          ans[s] = Rect(preColumn, preRow, preColumn + columnSize, preRow + bestRowSize);
          preColumn += columnSize;
        }
        curSmall += bestSmall;

        ans[curLarge] = Rect(preColumn, preRow, W, preRow + bestRowSize);
        curLarge--;
        preRow += bestRowSize;
      }

      foreach(r; ans) r.toString.writeln;
    }

    "FIN".deb;
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
