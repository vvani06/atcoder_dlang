void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto RND = Xorshift(0);

  int N = scan!int;
  int T = scan!int;
  int S = scan!int;
  long[][] WH = scan!long(N * 2).chunks(2).array;
  foreach(ref wh; WH) {
    wh[0] = clamp(wh[0], 10^^4, 10^^5);
    wh[1] = clamp(wh[1], 10^^4, 10^^5);
  }

  class Rect {
    int rectId;
    int rotated;
    int baseRectId;

    this(int id, int r, int b) {
      rectId = id;
      rotated = r;
      baseRectId = b;
    }

    this(int id, int r, int b, long x, long y) {
      rectId = id;
      rotated = r;
      baseRectId = b;
      sx = x;
      sy = y;
    }

    Rect dup() {
      return new Rect(rectId, rotated, baseRectId, sx, sy);
    }

    long sx, sy;

    int rotate() { return rotated = rotated ^ 1; }
    long w() { return WH[rectId][rotated]; }
    long h() { return WH[rectId][1 ^ rotated]; }
    long mins() { return WH[rectId].minElement; }
    long maxs() { return WH[rectId].maxElement; }
    long ex() { return sx + w(); }
    long ey() { return sy + h(); }

    string asOutput() {
      return format("%s %s %s %s", rectId, rotated, "L", baseRectId);
    }

    override string toString() {
      return format("%02d: [% 9s% 9s]", rectId, w(), h());
    }

    string asDimension() {
      return format("%02d: [% 9s% 9s] - [% 9s% 9s]", rectId, sx, sy, ex, ey);
    }

    void recalc(Rect[] rects) {
      sx = sy = 0;
      if (baseRectId != -1) {
        sy = rects[baseRectId].ey();
      }

      foreach(other; rects) {
        if (overlaped(other, 1, sy)) sx = max(sx, other.ex);
      }
    }

    bool overlaped(Rect other, int dir, long base) {
      long bx, by;
      if (dir == 0) { // U
        bx = base;
        by = other.ey - 1;
      } else { // L
        bx = other.ex - 1;
        by = base;
      }

      long dw = max(0, min(bx + w() + S, other.ex()) - max(bx, other.sx));
      long dh = max(0, min(by + h() + S, other.ey()) - max(by, other.sy));
      // [dw, dh].deb;
      return dw * dh > 0;
    }
  }

  long[] measureInteractive(Rect[] rects) {
    rects.length.writeln;
    foreach(r; rects) writeln(r.asOutput());
    stdout.flush();
    return scan!long(2);
  }

  long[] measure(Rect[] rects) {
    long w, h;
    foreach(i, r; rects) {
      r.recalc(rects[0..i]);
      w = max(w, r.ex);
      h = max(h, r.ey);
    }
    return [w, h];
  }

  int rc;
  while (T > N + 3) {
    rc++;
    foreach(i; 0..N) {
      writeln(1);
      writefln("%s %s %s %s", i, 0, "U", -1);
      stdout.flush();
      auto wh = scan!long(2);
      foreach(j; 0..2) WH[i][j] += clamp(wh[j], 10^^4, 10^^5);
    }
    T -= N;
  }
  foreach(i; 0..N) {
    WH[i][0] /= rc + 1;
    WH[i][1] /= rc + 1;
  }
  long baseHeight = WH.map!"a[0] * a[1]".sum.to!real.sqrt.to!long;

  Rect[] allRects;
  Tuple!(long[], Rect[]) testPack(long threshold, bool dryrun = false) {
    int pre = -1;

    Rect[] queue;
    long width;
    
    void resetColumn() {
      // queue.array.each!deb;
      // foreach(qr; queue) writeln(qr.asOutput());
      width = 0;
      allRects ~= queue;
      queue.length = 0;
    }
    
    foreach(i, whb; WH.enumerate(0)) {
      auto rect = new Rect(i, 0, queue.empty ? -1 : queue.back.rectId);
      width = max(width, rect.mins());
      queue ~= rect;

      long height;
      foreach(ref qr; queue) {
        if (abs(qr.w - width) > abs(qr.h - width)) qr.rotate();
        height += qr.h;
      }

      if (height >= threshold) {
        resetColumn();
      }
    }
    resetColumn();
    auto m = measure(allRects);
    return tuple(dryrun ? m : measureInteractive(allRects), allRects.dup);
  }

  const stepSize = baseHeight / 2000;
  long bestThreshold;
  long bestScore = long.max;

  enum STEPS = 250;
  foreach(step; -STEPS..STEPS + 1) {
    long th = baseHeight + step*stepSize;
    auto tested = testPack(th, true);
    allRects.length = 0;
    if (bestScore.chmin(tested[0].sum)) {
      bestThreshold = th;
    }
  }

  auto best = testPack(bestThreshold);
  T--;

  Rect[] curRects = best[1].map!"a.dup".array;
  Rect[] snapshot = best[1].map!"a.dup".array;
  long snapScore = best[0].sum;
  int badCount;
  int count;
  while(!elapsed(2500)) {
    count++;

    auto target = uniform(0, N, RND);
    if (count % 5 < 4) {
      curRects[target].rotate();
    } else {
      if (curRects[target].baseRectId == -1) continue;

      curRects[target].baseRectId = uniform(0, target, RND);
      curRects[target].rotated = uniform(0, 2, RND);
      foreach(n; curRects[target + 1..$]) {
        if (n.baseRectId == target) n.baseRectId--; 
      }
    }

    long w, h;
    foreach(i; 0..N) {
      curRects[i].recalc(curRects[0..i]);
      w = max(w, curRects[i].ex);
      h = max(h, curRects[i].ey);
    }
    if (w + h < snapScore) {
      snapshot = curRects.map!"a.dup".array;
      snapScore = w + h;
      badCount = 0;
      deb("update #", count, " => ", snapScore);
    } else if (w + h > snapScore * 1.2 || badCount >= 3) {
      curRects = snapshot.map!"a.dup".array;
      badCount = 0;
    } else {
      badCount++;
    }
  }

  deb("burned: ", count);

  foreach(_; 0..T) {
    writeln(snapshot.length);
    foreach(r; snapshot) writeln(r.asOutput());
    stdout.flush();
    scan!long(2);
  }
}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
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
