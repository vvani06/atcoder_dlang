void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  struct Color {
    double c, m, y;

    double[] asArrayD() { return [c, m, y]; }
    double[3] asArray() { return [c, m, y]; }

    double delta(Color other) {
      return pow(c - other.c, 2) + pow(m - other.m, 2) + pow(y - other.y, 2);
    }
  }

  int N = scan!int;
  int K = scan!int;
  int H = scan!int;
  int T = scan!int;
  int D = scan!int;
  auto D_ORG = D;
  Color[] OWN = K.iota.map!(_ => Color(scan!double, scan!double, scan!double)).array;
  Color[] TARGET = H.iota.map!(_ => Color(scan!double, scan!double, scan!double)).array;

  struct CompositeColor {
    int[] colorIds;
    Color color;
    double weight = 0;
    int weightI = 0;
    int index;

    this(int[] cids, int idx) {
      colorIds = cids.dup;
      weight = cids.length;
      weightI = cids.length.to!int;
      color = Color(
        cids.map!(a => OWN[a].c).mean,
        cids.map!(a => OWN[a].m).mean,
        cids.map!(a => OWN[a].y).mean,
      );
      index = idx;
    }

    this(Color c, int w) {
      weightI = w;
      weight = w;
      color = c;
    }

    double delta(Color other) { return color.delta(other); }
  }

  // ---------------------------------------------------------------------------------------------------------
  // ---------------------------------------------------------------------------------------------------------
  // ---------------------------------------------------------------------------------------------------------

  final class ColorServer {
    int maxCompositeCount;

    this(int mcc) {
      maxCompositeCount = mcc;
      build();
    }

    CompositeColor[] colors;
    int[Color][] idBySize;
    CompositeColor[][] colorsBySize;
    KDNode!(3LU, double)*[] kdTrees;

    void build() {
      colorsBySize = new CompositeColor[][](maxCompositeCount + 1, 0);
      DList!int picked;
      void dfs(int depth, int index, int maxDepth) {
        if (!picked.empty) {
          auto pa = picked.array;
          auto toAdd = CompositeColor(picked.array, colors.length.to!int);
          colors ~= toAdd;
          idBySize[pa.length].require(toAdd.color, colors.length.to!int - 1);
          colorsBySize[pa.length] ~= toAdd;
        } else {
          idBySize.length = maxDepth + 1;
        }
        if (depth >= maxDepth) return;

        foreach(i; index..K) {
          picked.insertBack(i);
          dfs(depth + 1, i, maxDepth);
          picked.removeBack();
        }
      }
      dfs(0, 0, maxCompositeCount);
      kdTrees = idBySize.length.iota.map!(i => KDNode!(3, double).build(idBySize[i].keys.map!"a.asArray".array)).array;
    }

    int nearest(Color target, int specifiedSize) {
      if (kdTrees.length < specifiedSize + 1) return -1;
      
      auto nearest = *(kdTrees[specifiedSize].nearest(target.asArray.kdPoint));
      return idBySize[specifiedSize][Color(nearest[0], nearest[1], nearest[2])];
    }

    CompositeColor* serve(int colorId) {
      return &(colors[colorId]);
    }
  }

  // ---------------------------------------------------------------------------------------------------------
  // ---------------------------------------------------------------------------------------------------------
  // ---------------------------------------------------------------------------------------------------------

  class Well {
    int id;
    double size;
    Color color;

    this(int id) {
      this.id = id;
      size = 0.0;
      color = Color(0, 0, 0);
    }

    this(int id, double s, Color c) {
      this.id = id;
      size = s;
      color = c;
    }

    Well dup() {
      return new Well(id, size, color);
    }
    
    void add(double otherSize, Color otherColor) {
      auto newSize = size + otherSize;
      color = Color(
        (color.c * size + otherColor.c * otherSize) / newSize,
        (color.m * size + otherColor.m * otherSize) / newSize,
        (color.y * size + otherColor.y * otherSize) / newSize,
      );
      size = newSize;
    }

    Color testAdd(Color other) {
      auto newSize = size + 1;
      return Color(
        (color.c * size + other.c) / newSize,
        (color.m * size + other.m) / newSize,
        (color.y * size + other.y) / newSize,
      );
    }

    Color testAdd(CompositeColor* other) {
      auto newSize = size + other.weight;
      return Color(
        (color.c * size + other.color.c * other.weight) / newSize,
        (color.m * size + other.color.m * other.weight) / newSize,
        (color.y * size + other.color.y * other.weight) / newSize,
      );
    }

    Color testAdd(Well other) {
      auto newSize = size + other.size;
      return Color(
        (color.c * size + other.color.c * other.size) / newSize,
        (color.m * size + other.color.m * other.size) / newSize,
        (color.y * size + other.color.y * other.size) / newSize,
      );
    }

    Color calcIdealColor(Color target, int anotherSize) {
      double s = size;
      double t = anotherSize;
      double[3] calced;
      foreach(i, a, c; zip(3.iota, color.asArrayD(), target.asArrayD())) {
        calced[i] = (c * (s + t) - s * a) / t;
      }
      return Color(calced[0], calced[1], calced[2]);
    }

    inout int opCmp(inout Well other) {
      return cmp(
        [id, size],
        [other.id, other.size],
      );
    }
  }

  final class State {
    int wellSize;

    int paletteSize;
    Well[] palette;
    int nextWellId;
    int nextTargetIndex;
    long useColorCount;
    double colorDeltaSum;
    string[] commands;
    State preState;
    double inkTotal = 0;

    int[][] togglePairs;
    int[][] togglePairsCell;
    bool[] closed;

    this(int wellSize = 10) {
      this.wellSize = wellSize;
      paletteSize = N * ((N - 1) / wellSize);
      colorDeltaSum = sqrt(3.0) * H;
      foreach(i; 0..paletteSize) {
        palette ~= new Well(i);
      }

      foreach(_; 0..N) commands ~= format("%(%s %)", 1.repeat(N - 1));
      foreach(r; 1..N) {
        int[] f;
        foreach(c; 0..N) {
          int x = r - c%2;
          f ~= x % wellSize == 0 ? 1 : 0;
        }
        commands ~= format("%(%s %)", f);
      }

      const limR = (N - 1) / wellSize;
      const limC = N;
      foreach(a; 0..paletteSize - 1) {
        auto ar = a / N;
        auto ac = a % N;

        auto arOffset = ac % 2;
        auto arHead = ar * wellSize + arOffset;
        auto arTail = arHead + wellSize - 1;

        if (ac < limC - 1) {
          togglePairs ~= [a, a + 1];
          auto realHead = arHead + 1 - arOffset;
          togglePairsCell ~= [realHead, ac, realHead, ac + 1];
        }
        
        if (ar < limR - 1) {
          togglePairs ~= [a, a + N];
          togglePairsCell ~= [arTail, ac, arTail + 1, ac];
        }
        
        if (ac % 2 == 1 && ar < limR - 1) {
          togglePairs ~= [a, a + N - 1];
          togglePairsCell ~= [arTail, ac, arTail, ac - 1];

          if (ac < limC - 1) {
            togglePairs ~= [a, a + N + 1];
            togglePairsCell ~= [arTail, ac, arTail, ac + 1];
          }
        }
      }
      closed = true.repeat(togglePairs.length).array;
    }

    int fixedPaletteSize() {
      return ((N / wellSize) - 1) * N;
    }

    State dup() {
      State ret = new State();
      ret.palette = palette.dup;
      ret.nextWellId = nextWellId;
      ret.nextTargetIndex = nextTargetIndex;
      ret.useColorCount = useColorCount;
      ret.colorDeltaSum = colorDeltaSum;
      ret.preState = this;
      return ret;
    }

    int wellRow(int wellId) {
      return (wellId / N) * wellSize + wellCol(wellId) % 2;
    }

    int wellCol(int wellId) {
      return (wellId % N);
    }

    Color testMerge(int toggleId) {
      auto a = palette[togglePairs[toggleId][0]];
      auto b = palette[togglePairs[toggleId][1]];
      return a.testAdd(b);
    }

    void addWell(int wellId, int colorId) {
      palette[wellId].add(1, OWN[colorId]);
      commands ~= "1 %s %s %s".format(wellRow(wellId), wellCol(wellId), colorId);
      useColorCount++;
      inkTotal += 1;
    }

    void decrease(int wellId) {
      if (palette[wellId].size > 0) {
        commands ~= "3 %s %s".format(wellRow(wellId), wellCol(wellId));
        palette[wellId].size -= 1.0;
        inkTotal -= 1;
      }
    }

    int toggledSize(int toggleId) {
      auto a = palette[togglePairs[toggleId][0]];
      auto b = palette[togglePairs[toggleId][1]];
      return a.size.to!int + b.size.to!int;
    }

    void toggle(int toggleId) {
      auto cell = togglePairsCell[toggleId];
      commands ~= "4 %s %s %s %s".format(cell[0], cell[1], cell[2], cell[3]);

      auto a = palette[togglePairs[toggleId][0]];
      auto b = palette[togglePairs[toggleId][1]];
      if (closed[toggleId]) {
        a.add(b.size, b.color);
        b.color = a.color;
        b.size = a.size;
      } else {
        b.color = a.color;
        b.size = a.size = a.size / 2;
      }
      closed[toggleId] ^= true;
    }

    void submit(int paletteId) {
      if (nextTargetIndex == H) return;
      auto target = TARGET[nextTargetIndex];

      palette[paletteId].size -= 1.0;
      nextTargetIndex++;
      colorDeltaSum += target.delta(palette[paletteId].color).sqrt() - sqrt(3.0);
      // deb("submit: ", target.delta(palette[paletteId].color).asScore());
      commands ~= "2 %s %s".format(wellRow(paletteId), wellCol(paletteId));
      inkTotal -= 1;
    }

    double calcScore() {
      if (nextTargetIndex != H) return int.max;
      if (commands.length > T + 39) return int.max / 8;

      return 1
        + (useColorCount - H) * D_ORG 
        + colorDeltaSum * 10^^4
      ;
    }

    override string toString() {
      return "State(submit: %s, score: %9.0f, turns: %s, deltas: %9.0f, costs: %8d, used: %s)".format(nextTargetIndex, calcScore, commands.length - 39, colorDeltaSum * 10^^4, (useColorCount - H)*D_ORG, useColorCount);
    }
  }

  // ---------------------------------------------------------------------------------------------------------
  // ---------------------------------------------------------------------------------------------------------
  // ---------------------------------------------------------------------------------------------------------

  enum LIMIT_MSEC = 2900;
  auto bestState = new State(1);
  //                       0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
  auto maxCompositeSize = [6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 5][K];
  auto maxDecreaseTry   = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 3, 3, 3, 2, 2][K];
  if (T < 5000) maxDecreaseTry = 2;
  auto server = new ColorServer(maxCompositeSize);

  void simulate(int maxAddAfterToggle, int[] wellSizes) {
    foreach(wellSize; wellSizes) {
      if (wellSize > maxCompositeSize) continue;

      if (elapsed(LIMIT_MSEC)) break;
      auto state = new State(wellSize);

      foreach(t, target; zip(H.iota, TARGET)) {
        if (elapsed(LIMIT_MSEC)) break;
        auto turnD = D <= 2400 ?
          max(0.0, pow(t.to!double / H.to!double, 10) * D) :
          max(state.inkTotal - (H - t), 0) * D;
        auto decD = max(0.0, D.to!double);

        auto extraTurn = min(20, T - state.commands.length.to!int - (H - t));
        decD = max(decD, 25 * (20 - extraTurn) / 20);
        turnD = max(turnD, 25 * (20 - extraTurn) / 20);

        int bestPalette, bestDecrease, bestColor, bestToggle, bestColorToggle;
        double bestScore = int.max;

        double toggleBestScore = int.max;
        foreach(tid, toggle; state.togglePairs.enumerate(0)) {
          auto ts = state.toggledSize(tid);
          if (ts < 1) continue;

          auto merged = state.testMerge(tid);
          if (ts >= 2) {
            auto score = merged.delta(target).asScore();
            if (bestScore.chmin(score)) {
              toggleBestScore = bestScore;
              bestToggle = tid;
              bestPalette = toggle[0];
              bestColorToggle = -1;
            }
          }

          if (maxAddAfterToggle > 0) {
            auto well = state.palette[toggle[0]].dup();
            well.color = merged;
            well.size += state.palette[state.togglePairs[tid][1]].size;
            foreach(addSize; 1..min(maxAddAfterToggle, state.wellSize*2 - well.size.to!int) + 1) {
              auto ideal = well.calcIdealColor(target, addSize);
              auto adder = server.nearest(ideal, addSize);
              auto mixed = well.testAdd(server.serve(adder));
              auto delta = mixed.delta(target);
              auto score = delta.asScore() + turnD*addSize;
              
              if (bestScore.chmin(score)) {
                toggleBestScore = bestScore;
                bestToggle = tid;
                bestPalette = toggle[0];
                bestColorToggle = adder;
                // deb("** ", well.size, " : ", state.palette[bestPalette].size, "|", state.palette[state.togglePairs[tid][1]].size, );
              }
            }
          }
        }

        bool visitedEmpty;
        foreach(pal; 0..state.paletteSize) {
          auto well = state.palette[pal];

          if (well.size <= 0) {
            if (visitedEmpty) continue; else visitedEmpty = true;
          }

          if (well.size >= 1) {
            if (bestScore.chmin(well.color.delta(target).asScore())) {
              bestPalette = pal;
              bestColor = -1;
            }
          }

          auto baseSize = well.size;
          foreach(dec; 0..max(1, min(maxDecreaseTry, well.size.to!int))) {
            if (decD*dec >= bestScore) break;

            well.size = baseSize - dec;
            foreach(addSize; 1..state.wellSize - well.size.to!int + 1) {
              if (addSize > maxCompositeSize) break;
              if (turnD*addSize + decD*dec >= bestScore) break;

              auto ideal = well.calcIdealColor(target, addSize);
              auto adder = server.nearest(ideal, addSize);
              auto mixed = well.testAdd(server.serve(adder));
              auto delta = mixed.delta(target);
              auto score = delta.asScore() + decD*dec + turnD*addSize;
              
              if (bestScore.chmin(score)) {
                bestPalette = pal;
                bestDecrease = dec;
                bestColor = adder;
              }
            }
          }
          well.size = baseSize;
        }

        bool isBestToggle = toggleBestScore == bestScore;
        int toggleOdd;

        if (isBestToggle) {
          // deb("* ", state.palette[bestPalette].size);
          // deb("* ", state.palette[state.togglePairs[bestToggle][1]].size);
          state.toggle(bestToggle);
          if (bestColorToggle != -1) {
            // deb("* ", state.palette[bestPalette].size, " + ", server.serve(bestColorToggle).colorIds.length);
            foreach(c; server.serve(bestColorToggle).colorIds) state.addWell(bestPalette, c);
          }
          // deb("* toggle: ", bestScore);
          toggleOdd = state.palette[bestPalette].size.to!int % 2;
        } else if (bestColor >= 0) {
          foreach(_; 0..bestDecrease) state.decrease(bestPalette);
          foreach(c; server.serve(bestColor).colorIds) state.addWell(bestPalette, c);
        }

        if (isBestToggle && !toggleOdd) state.toggle(bestToggle);
        state.submit(bestPalette);
        if (isBestToggle && toggleOdd) state.toggle(bestToggle);
      }
      if (elapsed(LIMIT_MSEC)) break;

      state.deb;
      "---------------------------------------------------------------------------------------".deb;
      if (bestState.calcScore() > state.calcScore()) {
        bestState = state;
      }
    }
  }

  simulate(0, [3]);
  foreach(maxAddAfterToggle; [0, 1, 5]) {
    int[] wellSizes = [6, 5];
    if (D >= 40) wellSizes = [4, 5, 6];
    if (D >= 100) wellSizes = [3, 4];
    if (T <= 5500) wellSizes = [3, 4, 5, 6];

    simulate(maxAddAfterToggle, wellSizes);
  }

  foreach(c; bestState.commands) writeln(c);
  bestState.calcScore.deb;
  double extra = 0;
  foreach(w; bestState.palette) extra += w.size;
  (extra * D).deb;
}

// ----------------------------------------------

import std;
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
double asScore(double d) { return d.sqrt * 10^^4; }

// -----------------------------------------------


struct KDNode(size_t k, T) if(k > 0)
{
    KDPoint!(k, T) point;

    KDNode!(k, T) *left  = null;
    KDNode!(k, T) *right = null;

    this(KDPoint!(k, T) point)
    {
        this.point = point;
    }

    static KDNode!(k, T) *build(T[k][] points...)
    {
        return build(KDPoint!(k, T).build(points));
    }

    static KDNode!(k, T) *build(KDPoint!(k, T)[] points, size_t depth = 0)
    {
        if(points.length > 1)
        {
            auto axis = depth % k;

            auto sorted = points.sortedOn(axis);
            auto median = sorted[$ / 2];

            auto node = new KDNode!(k, T)(median);

            if(sorted.length / 2 > 0)
            {
                node.left = build(sorted[0 .. $ / 2], depth + 1);
            }
            if(sorted.length / 2 + 1 < sorted.length)
            {
                node.right = build(sorted[$ / 2 + 1 .. $], depth + 1);
            }

            return node;
        }
        else if(points.length == 1)
        {
            return new KDNode!(k, T)(points[0]);
        }
        else
        {
            return null;
        }
    }

    @property
    bool leaf() const
    {
        return left is null && right is null;
    }
}

KDPoint!(k, T) *nearest(size_t k, T)(KDNode!(k, T) *root, KDPoint!(k, T) neighbour) if(k > 0)
{
    KDPoint!(k, T) *nearest = null;
    double nearestDistance = double.max;

    void nearestImpl(KDNode!(k, T) *current, KDPoint!(k, T) point, size_t depth = 0)
    {
        if(current !is null)
        {
            auto axis = depth % k;

            double distance = current.point.distanceSq(point);
            double distanceAxis = (current.point[axis] - point[axis]) ^^ 2;

            if(nearest is null || distance < nearestDistance)
            {
                nearestDistance = distance;
                nearest = &current.point;
            }

            if(nearestDistance > 0)
            {
                auto next = distanceAxis > 0 ? current.left : current.right;
                nearestImpl(next, point, depth + 1);

                if(distanceAxis <= nearestDistance)
                {
                    next = distanceAxis > 0 ? current.right : current.left;
                    nearestImpl(next, point, depth + 1);
                }
            }
        }
    }
    nearestImpl(root, neighbour);
    return nearest;
}

struct KDPoint(size_t k, T) if(k > 0)
{
    T[k] state;

    this(T[k] state...)
    {
        this.state = state;
    }

    static KDPoint!(k, T)[] build(T[k][] points...)
    {
        return points.map!(p => KDPoint!(k, T)(p)).array;
    }

    double distanceSq(KDPoint!(k, T) other) const
    {
        return iota(0, k)
            .map!(i => state[i] - other.state[i])
            .map!"a ^^ 2"
            .sum;
    }

    @property
    enum size_t length = k;

    T opIndex(size_t axis)
    {
        return state[axis];
    }

    T[] opSlice(size_t start, size_t stop)
    {
        return state[start .. stop];
    }

    bool opEquals(KDPoint!(k, T) other) const
    {
        return state == other.state;
    }
}

@property
KDPoint!(k, T) kdPoint(size_t k, T)(T[k] point) if(k > 0)
{
    return KDPoint!(k, T)(point);
}

@property
KDPoint!(k, T) kdPoint(size_t k, T)(T[] point) if(k > 0)
{
    return KDPoint!(k, T)(point[0 .. k]);
}

@property
KDPoint!(k, T)[] sortedOn(size_t k, T)(KDPoint!(k, T)[] points, size_t axis) if(k > 0)
{
    return points.sort!((a, b) => a[axis] < b[axis]).array;
}
