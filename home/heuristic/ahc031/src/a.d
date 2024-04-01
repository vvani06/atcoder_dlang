void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto RND = Xorshift(0);

  int W = scan!int;
  int D = scan!int;
  int N = scan!int;
  int[][] A = scan!int(D * N).chunks(N).array;

  int restEffort = 2850;
  auto checkedTime = MonoTime.currTime();
  void checkTime() { checkedTime = MonoTime.currTime(); }
  bool elapsedFromChecked(int ms) { return ms <= (MonoTime.currTime() - checkedTime).total!"msecs"; }
  void useTimeFromChecked() { restEffort -= (MonoTime.currTime() - checkedTime).total!"msecs"; }
  int restDay = D + 1;

  long E = (W^^2 * D - A.map!sum.sum) / D;
  [[E]].deb;

  struct Rect {
    int l, t, r, b;
    int rectId, requiredSegment;

    int rowSize() { return b - t; }
    int columnSize() { return r - l; }
    int segment() { return rowSize * columnSize; }

    string toString() {
      return "%(%d %)".format([l, t, r, b]);
    }

    long penalty() {
      return max(0L, requiredSegment - segment());
    }
  }

  struct PredefinedRect {
    int rectId, offset, rowSize, usedColumn, rowId;

    bool use(int columnSize, int requiredRestSegment) {
      if (rowSize * (W - usedColumn - columnSize) < requiredRestSegment) return false;

      usedColumn += columnSize;
      return true;
    }
  }
  
  struct Day {
    bool usePredefinedLayout;
    Rect[][] rects;

    this(bool up, Rect[] rects) {
      usePredefinedLayout = up;
      foreach(rc; rects.multiSort!("a.t < b.t", "a.l < b.l").chunkBy!"a.t") {
        this.rects ~= rc[1].array;
      }
    }

    void output() {
      string[] outputs = new string[](N);
      foreach(r; rects.joiner) {
        outputs[r.rectId] = r.toString;
      }

      foreach(o; outputs) o.writeln;
      "".writeln;
    }

    int[] memoRectCountsByRow;
    int[] rectCountsByRow() {
      if (!usePredefinedLayout) return 0.repeat(N).array;
      return memoRectCountsByRow = rects.map!"a.length.to!int".array;
    }

    Day shiftOnePixel(int row) {
      if (row >= rects.length - 1) return this;

      Rect[] shifted = rects[0..row].joiner.array;
      foreach(r; rects[row]) {
        shifted ~= r;
        shifted[$ - 1].b--;
      }
      foreach(r; rects[row + 1..$].joiner) {
        shifted ~= r;
        shifted[$ - 1].t--;
        if (shifted[$ - 1].b != W) shifted[$ - 1].b--;
      }
      return Day(usePredefinedLayout, shifted);
    }

    long penalty() {
      return rects.joiner.map!(r => r.penalty()).sum;
    }
  }

  Rect[] rectsBySegments(int[] segs) {
    return N.iota.map!(i => Rect(0, 0, 0, 0, i, segs[i])).array;
  }

  Day solveDayWithTwoPointers(int[] segs) {
    Rect[] rects = rectsBySegments(segs);
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
        foreach(rowSize; baseRowSize .. min(W - preRow, baseRowSize + 100)) {
          int l = segs[curSmall..curSmall + small].map!(s => (s + rowSize - 1) / rowSize).sum;
          int segLack = max(0, segs[curLarge] - (W - l) * rowSize);
          
          if (waste.chmin(segLack*100 + rowSize * W - seg)) {
            bestSmall = small;
            bestRowSize = rowSize;
          }
        }
      }

      int preColumn;
      foreach(s; curSmall..curSmall + bestSmall) {
        int columnSize = (segs[s] + bestRowSize - 1) / bestRowSize;
        rects[s] = Rect(preColumn, preRow, preColumn + columnSize, preRow + bestRowSize, s, segs[s]);
        preColumn += columnSize;
      }
      curSmall += bestSmall;

      rects[curLarge] = Rect(preColumn, preRow, W, preRow + bestRowSize, curLarge, segs[curLarge]);
      curLarge--;
      preRow += bestRowSize;
    }

    foreach(i; 0..N) if (rects[i].b == preRow) rects[i].b = W;

    auto candidate = Day(false, rects);
    if (candidate.penalty > 0) {
      foreach(_; 0..8) {
        long bestPenalty = candidate.penalty;
        Day bestShifted;
        foreach(r; 0..candidate.rects.length.to!int - 1) {
          auto shifted = candidate.shiftOnePixel(r);
          if (bestPenalty.chmin(shifted.penalty)) {
            bestShifted = shifted;
          }
        }

        if (bestPenalty >= candidate.penalty) break;
        candidate = bestShifted;
      }
    }
    return candidate;
  }

  Day[] solveWithPredefinedRects() {
    Day[] ret;

    auto sortedPerRectId = N.iota.map!(i => A.map!(a => a[i]).array.sort).array;
    // sortedPerRectId.each!deb;

    auto maximums = N.iota.map!(i => A.map!(a => a[i] >= W^^2 / 2 ? 0 : a[i]).maxElement).array;
    // maximums.deb;
    // maximums[$ - 3..$].sum.deb;
    // A.map!(a => (W^^2 - a.sum)*10000L / W^^2).deb;

    Rect[] preDefRects = rectsBySegments(A[0]);
    PredefinedRect[] predefined = new PredefinedRect[](0); {
      int preDefRow, rowId;
      foreach_reverse(i; 0..N) {
        int rowSize = (maximums[i] + W - 1) / W + 12;

        if (E <= 9000) {
          if (preDefRow >= W * (65 + N/2) / 100) rowSize = W - preDefRow;
        } else {
          if (preDefRow >= W * (75 + N/3) / 100) rowSize = W - preDefRow;
        }
        if (rowSize * W < maximums[i]) {
          predefined[$ - 1].rowSize += W - preDefRow;
          preDefRects[i + 1].b = W;
          break;
        }
        rowSize = min(rowSize, W - preDefRow);

        preDefRects[i] = Rect(0, preDefRow, W, preDefRow + rowSize, i, maximums[i]);
        predefined ~= PredefinedRect(i, preDefRow, rowSize, 0, rowId++);
        preDefRow += rowSize;

        if (preDefRow >= W) break;
      }
    }

    auto predefinedIndicies = predefined.length.to!int.iota.array;
    auto restIndicied = (N - predefined.length).to!int.iota.array;

    foreach(segs; A) {
      restDay--;

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
      foreach(i; 0..N) rects[i].requiredSegment = segs[i];

      Day preDay = ret.empty ? Day() : ret[$ - 1];
      {
        int numPlaced;
        PredefinedRect[] predef = predefined.dup;
        foreach(i; (N - predef.length.to!int).iota) {
          foreach(ref p; predef.sort!"a.rowSize < b.rowSize") {
            int columnSize = (segs[i] + p.rowSize - 1) / p.rowSize;
            if (p.use(columnSize, segs[p.rectId])) {
              rects[i] = Rect(p.usedColumn - columnSize, p.offset, p.usedColumn, p.offset + p.rowSize, i, segs[i]);
              rects[p.rectId].l = p.usedColumn;
              numPlaced++;
              break;
            }
          }
        }

        if (numPlaced == N - predef.length) {
          ret ~= Day(true, rects);
          continue;
        }
      }

      auto indicies = (N - predefined.length).to!int.iota.array;
      enum INF = long.max / 100;
      long bestPenalty = INF;
      auto bestRects = rects.dup;
      int[] baseRectCountsByRow = 1.repeat(preDay.rectCountsByRow.length).array;
      int[] bestRectCountsByRow = 1.repeat(preDay.rectCountsByRow.length).array;

      auto loopTime = restEffort / restDay;
      auto rowSizes = predefined.map!"a.rowSize".array;
      checkTime();
      while(!elapsedFromChecked(loopTime)) {
        scope PredefinedRect[] predef = predefined.dup;
        scope int placed;
        scope int[] rectCountsByRow = baseRectCountsByRow.dup;

        foreach_reverse(i; indicies) {
          foreach(pi; predefinedIndicies.randomShuffle(RND)) {
            auto p = &predef[pi];
            int columnSize = (segs[i] + p.rowSize - 1) / p.rowSize;
            if (p.use(columnSize, segs[p.rectId])) {
              rects[i] = Rect(p.usedColumn - columnSize, p.offset, p.usedColumn, p.offset + p.rowSize, i, segs[i]);
              rects[p.rectId].l = p.usedColumn;
              placed++;
              rectCountsByRow[p.rowId]++;
              break;
            }
          }
        }

        int penalty;
        foreach(r, rowSize; rowSizes) {
          penalty += rectCountsByRow[r] * rowSize / 5;
          penalty += abs(rectCountsByRow[r] - preDay.rectCountsByRow[r]) * rowSize;
          // abs(a - b) ^^ 2;
        }

        if (placed == indicies.length && bestPenalty.chmin(penalty)) {
          bestRects = rects.dup;
          bestRectCountsByRow = rectCountsByRow.dup;
        }
        if (bestPenalty == 0) break;
      }
      useTimeFromChecked();

      if (bestPenalty < INF) {
        bestPenalty.deb;
        [preDay.rectCountsByRow, bestRectCountsByRow].deb;
        ret ~= Day(true, bestRects);
      } else {
        ret ~= solveDayWithTwoPointers(segs);
      }
    }

    return ret;
  }

  auto ans = solveWithPredefinedRects();

  bool expand(Rect[] rc, int i, int r) {
    if (rc[i].r >= r) return false;

    int diff = r - rc[i].r;
    int diffSeg = diff * rc[i].rowSize;
    if (rc[$ - 1].segment - diffSeg < rc[$ - 1].requiredSegment) return false;

    rc[i].r += diff;
    foreach(j; i + 1..rc.length) {
      rc[j].l += diff;
      rc[j].r = min(W, rc[j].r + diff);
    }
    return true;
  }

  foreach(d; 0..D) {
    foreach(rects; ans[d].rects) {
      rects[0].l = 0;
    }
  }

  foreach(t; 0..300) foreach(d; 0..D - 1) {
    if (!(ans[d].usePredefinedLayout && ans[d + 1].usePredefinedLayout)) continue;

    foreach(row; 0..ans[d].rects.length.to!int) {
      auto rects = [ans[d].rects[row], ans[d + 1].rects[row]];

      foreach(i; 0..min(rects[0].length.to!int, rects[1].length.to!int)) {
        auto larger = max(rects[0][i].r, rects[1][i].r);
        expand(rects[0], i, larger);
        expand(rects[1], i, larger);
      }
    }
  }

  int[100][100] adjusted;
  foreach_reverse(baseDay; 1..D) {
    auto baseRects = ans[baseDay].rects;
    if (!ans[baseDay].usePredefinedLayout) continue;

    foreach(row; 0..baseRects.length.to!int - 1) {
      foreach(baseColumn; 0..baseRects[row].length.to!int - 1) {
        int base = baseRects[row][baseColumn].r;

        foreach_reverse(day; 0..baseDay) {
          if (!ans[day].usePredefinedLayout) break;

          auto target = ans[day].rects[row];
          int c = adjusted[day][row];
          while(target[min(c + 1, $ - 1)].r < base) c++;

          // [target].deb;
          // [baseDay, day, row, base, c].deb;
          if (expand(target, c, base)) {
            adjusted[day][row] = c + 1;
          } else {
            break;
          }
        }
      }
    }
  }

  foreach(d; 0..D - 1) {
    if (!(ans[d].usePredefinedLayout && ans[d + 1].usePredefinedLayout)) continue;

    foreach(row; 0..ans[d].rects.length.to!int) {
      auto rects = [ans[d].rects[row], ans[d + 1].rects[row]];

      int i, j;
      while(i < rects[0].length && j < rects[1].length) {
        if (rects[0][i].r < rects[1][j].r) {
          i++;
          continue;
        }

        if (expand(rects[1], j, rects[0][i].r)) i++;
        j++;
      }
    }
  }

  debug {
    // ans.deb;
    "--- FIN ---".deb;
    (MonoTime.currTime() - StartTime).total!"msecs".deb;
  } else {
    foreach(day; ans) day.output();
  }
}

// ----------------------------------------------

import std;
import core.memory : GC;
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
