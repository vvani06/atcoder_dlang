void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

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

  struct PredefinedRect {
    int rectId, offset, rowSize, usedColumn;

    bool use(int columnSize, int requiredRestSegment) {
      if (rowSize * (W - usedColumn - columnSize) < requiredRestSegment) return false;

      usedColumn += columnSize;
      return true;
    }
  }

  Rect[] solveDayWithTwoPointers(int[] segs) {
    Rect[] rects = new Rect[](N);

    int preRow;
    int curLarge = N - 1;
    int curSmall = 0;
    
    while(curLarge >= curSmall) {
      int waste = int.max;
      int bestSmall, bestRowSize = W - preRow;
      foreach(small; 0..min(12, curLarge - curSmall + 1)) {
        int seg = segs[curLarge];
        foreach(i; curSmall..curSmall + small) seg += segs[i];

        int baseRowSize = (seg + W - 1) / W;
        foreach(rowSize; baseRowSize .. min(W - preRow, baseRowSize + 250)) {
          int l = segs[curSmall..curSmall + small].map!(s => (s + rowSize - 1) / rowSize).sum;
          int segLack = max(0, segs[curLarge] - (W - l) * rowSize);
          
          if (waste.chmin(segLack*100 + rowSize * W - seg)) {
            bestSmall = small;
            bestRowSize = rowSize;
          }
        }
      }

      [bestSmall, bestRowSize].deb;
      int preColumn;
      foreach(s; curSmall..curSmall + bestSmall) {
        int columnSize = (segs[s] + bestRowSize - 1) / bestRowSize;
        rects[s] = Rect(preColumn, preRow, preColumn + columnSize, preRow + bestRowSize);
        preColumn += columnSize;
      }
      curSmall += bestSmall;

      rects[curLarge] = Rect(preColumn, preRow, W, preRow + bestRowSize);
      curLarge--;
      preRow += bestRowSize;
    }

    foreach(i; 0..N) if (rects[i].b == preRow) rects[i].b = W;
    return rects;
  }

  Rect[][] solveWithTwoPointers() {
    Rect[][] ret;

    foreach(segs; A) {
      ret ~= solveDayWithTwoPointers(segs);
    }
    return ret;
  }

  auto solveWithPredefinedRects() {
    Rect[][] ret;

    auto sortedPerRectId = N.iota.map!(i => A.map!(a => a[i]).array.sort).array;
    sortedPerRectId.each!deb;

    auto maximums = N.iota.map!(i => A.map!(a => a[i] > W^^2 / 2 ? 0 : a[i]).maxElement).array;
    maximums.deb;
    maximums[$ - 3..$].sum.deb;
    A.map!(a => (W^^2 - a.sum)*10000L / W^^2).deb;

    auto preDefRects = new Rect[](N);
    PredefinedRect[] predefined = new PredefinedRect[](0); {
      int preDefRow;
      foreach_reverse(i; 0..N) {
        int rowSize = (maximums[i] + W - 1) / W + 15;
        [[[preDefRow]]].deb;
        if (preDefRow >= W * (65 + N/2) / 100) rowSize = W - preDefRow;
        if (rowSize * W < maximums[i]) {
          predefined[$ - 1].rowSize += W - preDefRow;
          preDefRects[i + 1].b = W;
          break;
        }

        preDefRects[i] = Rect(0, preDefRow, W, preDefRow + rowSize);
        predefined ~= PredefinedRect(i, preDefRow, rowSize, 0);
        preDefRow += rowSize;

        if (preDefRow >= W) break;
      }
    }

    foreach(segs; A) {
      bool cannotUsePredefinedLayout;
      foreach(i, p; predefined) {
        if (p.rowSize * W < segs[$ - i - 1]) {
          cannotUsePredefinedLayout = true;
        }
      }

      if (cannotUsePredefinedLayout) {
        ret ~= solveDayWithTwoPointers(segs);
        continue;
      }

      Rect[] rects = preDefRects.dup;

      int tried;
      LOOP: foreach(_; 0..10000) {
        tried++;
        PredefinedRect[] predef = predefined.dup;
        foreach_reverse(i; (N - predef.length).iota.array.randomShuffle) {
          bool placed;
          foreach(ref p; predef.randomShuffle) {
            int columnSize = (segs[i] + p.rowSize - 1) / p.rowSize;
            if (p.use(columnSize, segs[p.rectId])) {
              rects[i] = Rect(p.usedColumn - columnSize, p.offset, p.usedColumn, p.offset + p.rowSize);
              rects[p.rectId].l = p.usedColumn;
              placed = true;
              break;
            }
          }

          if (!placed) continue LOOP;
        }
        break;
      }

      if (tried < 10000) {
        ret ~= rects;
      } else {
        ret ~= solveDayWithTwoPointers(segs);
      }
    }

    return ret;
  }

  auto ans = solveWithTwoPointers();
  auto ansPredefined = solveWithPredefinedRects();
  if (ansPredefined !is null) ans = ansPredefined;

  foreach(rectsPerDay; ans) {
    foreach(rect; rectsPerDay) rect.toString().writeln;
    "".writeln;
  }

  "--- FIN ---".deb;
  (MonoTime.currTime() - StartTime).total!"msecs".deb;
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
