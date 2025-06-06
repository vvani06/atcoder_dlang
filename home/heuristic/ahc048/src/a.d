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

    int nearest(Color target, int[] specifiedSize = []) {
      double bestDelta = int.max;
      int ret;

      foreach(colorSize, tree; kdTrees[1..$].enumerate(1)) {
        if (!specifiedSize.empty && !specifiedSize.canFind(colorSize)) continue;

        auto nearest = *(tree.nearest(target.asArray.kdPoint));
        auto nci = idBySize[colorSize][Color(nearest[0], nearest[1], nearest[2])];
        if (bestDelta.chmin(target.delta(colors[nci].color))) ret = nci;
      }
      return ret;
    }

    CompositeColor serve(int colorId) {
      return colors[colorId];
    }
    int[] serveOwnColors(int colorId) {
      return colors[colorId].colorIds;
    }

    CompositeColor[] serveBySize(int size) {
      return colorsBySize[size];
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

    Color testAdd(CompositeColor other) {
      auto newSize = size + other.weight;
      return Color(
        (color.c * size + other.color.c * other.weight) / newSize,
        (color.m * size + other.color.m * other.weight) / newSize,
        (color.y * size + other.color.y * other.weight) / newSize,
      );
    }

    Color calcIdealColor(Color target, int anotherSize) {
      double s = size;
      double t = anotherSize;
      double[] calced;
      foreach(a, c; zip(color.asArrayD(), target.asArrayD())) {
        calced ~= (c * (s + t) - s * a) / t;
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

    Well[int] palette;
    int nextWellId;
    int nextTargetIndex;
    long useColorCount;
    double colorDeltaSum;
    string[] commands;
    State preState;

    this(int wellSize = 10) {
      this.wellSize = wellSize;
      colorDeltaSum = sqrt(3.0) * H;
      foreach(i; 0..N^^2 / wellSize) {
        palette[i] = new Well(i);
      }

      foreach(_; 0..N)  commands ~= format("%(%s %)", 1.repeat(N - 1));
      foreach(_; 1..N)  commands ~= format("%(%s %)", (_ % wellSize == 0 ? 1 : 0).repeat(N));
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
      return (wellId / N) * wellSize;
    }

    int wellCol(int wellId) {
      return (wellId % N);
    }

    void addWell(int wellId, int colorId) {
      palette[wellId].add(1, OWN[colorId]);
      commands ~= "1 %s %s %s".format(wellRow(wellId), wellCol(wellId), colorId);
      useColorCount++;
    }

    void decrease(int wellId) {
      if (palette[wellId].size > 0) {
        commands ~= "3 %s %s".format(wellRow(wellId), wellCol(wellId));
        palette[wellId].size -= 1.0;
      }
    }

    void clearWell(int wellId) {
      while (palette[wellId].size > 0) {
        commands ~= "3 %s %s".format(wellRow(wellId), wellCol(wellId));
        palette[wellId].size -= 1.0;
      }
    }

    int provisionWell() {
      int use;
      double mini = int.max;
      foreach(i; 0..N) {
        if (mini.chmin(palette[i].size)) use = i;
      }
      clearWell(use);
      return use;
    }

    void submitBestColor() {
      if (nextTargetIndex == H) return;
      auto target = TARGET[nextTargetIndex];

      double bestDelta = int.max;
      int bestWell;
      foreach(w, well; palette) {
        if (well.size >= 1.0 && bestDelta.chmin(target.delta(well.color))) bestWell = w;
      }

      if (bestDelta == int.max) return;

      palette[bestWell].size -= 1.0;
      nextTargetIndex++;
      colorDeltaSum += sqrt(bestDelta) - sqrt(3.0);
      commands ~= "2 %s %s".format(wellRow(bestWell), wellCol(bestWell));
    }

    void submit(int paletteId) {
      if (nextTargetIndex == H) return;
      auto target = TARGET[nextTargetIndex];

      palette[paletteId].size -= 1.0;
      nextTargetIndex++;
      colorDeltaSum += target.delta(palette[paletteId].color).sqrt() - sqrt(3.0);
      commands ~= "2 %s %s".format(wellRow(paletteId), wellCol(paletteId));
    }

    double calcScore() {
      if (commands.length > T + 39) return int.max;

      return 1
        + (useColorCount - H) * D 
        + colorDeltaSum * 10^^4
      ;
    }
  }

  // ---------------------------------------------------------------------------------------------------------
  // ---------------------------------------------------------------------------------------------------------
  // ---------------------------------------------------------------------------------------------------------

  auto bestState = new State(1);
  auto server = new ColorServer(6);
  
  // foreach(wellSize; [-1]) {
  foreach(wellSize; [3, 4, 5, 6]) {
    if (wellSize < 0) break;
    auto state = new State(wellSize);
    
    int[int] bestColorFreq;
    int[] bestColors = new int[](H);
    foreach(i, target; TARGET) {
      int bestColor = server.nearest(target, iota(1, wellSize + 1).array);
      bestColorFreq[bestColor]++;
      bestColors[i] = bestColor;
    }

    int[int] bestPalette;
    {
      int tt;
      foreach(k; bestColorFreq.keys.sort!((a, b) => bestColorFreq[a] > bestColorFreq[b])) {
        auto weight = server.colors[k].weightI;
        auto rem = bestColorFreq[k] % weight;
        if (weight > 1) {
          if (tt < state.fixedPaletteSize) {
            bestPalette[k] = N + tt;
            // [tt, k, bestColorFreq[k], weight].deb;
            tt++;
          }
        }
      }
    }

    foreach(target, fixedColor; zip(TARGET, bestColors)) {
      if (fixedColor in bestPalette) {
        auto use = bestPalette[fixedColor];

        if (state.palette[use].size > 0 || bestColorFreq[fixedColor] > server.colors[fixedColor].weightI / 2) {
          bestColorFreq[fixedColor]--;
          if (state.palette[use].size <= 0) {
            foreach(c; server.colors[fixedColor].colorIds) state.addWell(use, c);
          }
          state.submitBestColor();
          continue;
        }
      }

      double bestScore = int.max;
      int bestMode = -1;
      int bestColor, reusePalette;

      // 既存色をそのまま提出
      foreach(i; 0..N) {
        if (state.palette[i].size < 1.0) continue;
        
        if (bestScore.chmin(target.delta(state.palette[i].color).asScore())) {
          bestMode = 0;
          reusePalette = i;
        }
      }

      // 既存色に CompositeColor を加えて提出
      foreach(i; 0..N) {
        if (state.palette[i].size < 1.0) continue;

        foreach(addSize; [1, 2]) {
          if (state.palette[i].size + addSize > state.wellSize) continue;

          auto cost = D * addSize;
          foreach(compositeColor; server.serveBySize(addSize)) {
            auto addedColor = state.palette[i].testAdd(compositeColor);
            
            if (bestScore.chmin(cost + target.delta(addedColor).asScore())) {
              bestMode = 1;
              reusePalette = i;
              bestColor = compositeColor.index;
            }
          }
        }
      }

      // 新規に CompositeColor を作成して提出。場合によっては廃棄を伴う
      foreach(times; 1..state.wellSize + 1) {
        auto compositeColorId = server.nearest(target, [times]);
        auto score = target.delta(server.serve(compositeColorId).color).asScore();
        score += times * D;
        if (bestScore.chmin(score)) {
          bestMode = 2;
          bestColor = compositeColorId;
        }
      }

      if (bestMode == 0) {
        state.submitBestColor();
      } else if (bestMode == 1) {
        foreach(c; server.serveOwnColors(bestColor)) state.addWell(reusePalette, c);
        state.submitBestColor();
      } else {
        auto use = state.provisionWell();
        foreach(c; server.serveOwnColors(bestColor)) state.addWell(use, c);
        state.submitBestColor();
      }
    }

    if (bestState.calcScore() > state.calcScore()) {
      bestState = state;
    }
  }

  foreach(wellSize; T <= 5000 ? [4]: [5]) {
    auto state = new State(wellSize);
    auto paletteCount = N^^2 / state.wellSize;

    foreach(t, target; zip(H.iota, TARGET)) {
      const turnD = pow(t.to!double / H.to!double, 4) * D;
      const decD = D.to!double;

      if (elapsed(2800)) break;
      int bestPalette, bestDecrease, bestColor;
      double bestScore = int.max;

      foreach(pal; 0..paletteCount) {
        auto well = state.palette[pal];

        if (well.size >= 1) {
          if (bestScore.chmin(well.color.delta(target).asScore())) {
            bestPalette = pal;
            bestColor = -1;
          }
        }

        auto baseSize = well.size;
        foreach(dec; 0..min(3, well.size.to!int + 1)) {
          if (decD*dec >= bestScore) break;

          well.size = baseSize - dec;
          foreach(addSize; 1..state.wellSize - well.size.to!int + 1) {
            if (turnD*addSize + decD*dec >= bestScore) break;

            auto ideal = well.calcIdealColor(target, addSize);
            auto adder = server.nearest(ideal, [addSize]);
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

      if (bestColor >= 0) {
        foreach(_; 0..bestDecrease) state.decrease(bestPalette);
        foreach(c; server.serve(bestColor).colorIds) state.addWell(bestPalette, c);
      }
      state.submit(bestPalette);
    }

    if (elapsed(2800)) break;
    bestState.calcScore().deb;
    if (bestState.calcScore() > state.calcScore()) {
      bestState = state;
    }
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
