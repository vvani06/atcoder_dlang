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

  struct WeightedColor {
    int[] colorIds;
    Color color;
    double weight;

    this(int[] cids) {
      colorIds = cids.dup;
      weight = cids.length;
      color = Color(
        cids.map!(a => OWN[a].c).mean,
        cids.map!(a => OWN[a].m).mean,
        cids.map!(a => OWN[a].y).mean,
      );
    }

    double delta(Color other) { return color.delta(other); }
  }

  WeightedColor[] WC;
  int[Color][] WCI;

  {
    DList!int picked;
    void dfs(int depth, int index, int maxDepth) {
      if (!picked.empty) {
        auto pa = picked.array;
        WC ~= WeightedColor(picked.array);
        WCI[pa.length].require(WC[$ - 1].color, WC.length.to!int - 1);
      } else {
        WCI.length = maxDepth + 1;
      }
      if (depth >= maxDepth) return;

      foreach(i; index..K) {
        picked.insertBack(i);
        dfs(depth + 1, i, maxDepth);
        picked.removeBack();
      }
    }
    
    dfs(0, 0, T <= 5000 ? 2 : 5);
  }

  WC.length.deb;
  auto kdTree = WCI.length.iota.map!(i => KDNode!(3, double).build(WCI[i].keys.map!"a.asArray".array)).array;

  foreach(_; 0..N) {
    writefln("%(%s %)", 1.repeat(N - 1));
  }
  foreach(_; 1..N) {
    writefln("%(%s %)", 0.repeat(N));
  }

  struct Well {
    int id;
    double size;
    Color color;
    
    Well add(double otherSize, Color otherColor) {
      auto newSize = size + otherSize;
      return Well(
        id,
        newSize,
        Color(
          (color.c * size + otherColor.c * otherSize) / newSize,
          (color.m * size + otherColor.m * otherSize) / newSize,
          (color.y * size + otherColor.y * otherSize) / newSize,
        ),
      );
    }

    inout int opCmp(inout Well other) {
      return cmp(
        [id, size],
        [other.id, other.size],
      );
    }
  }

  class State {
    Well[int] palette;
    int nextWellId;
    int nextTargetIndex;
    long useColorCount;
    double colorDeltaSum;
    string[] commands;

    this() {
      colorDeltaSum = sqrt(3.0) * H;
    }

    State dup() {
      State ret = new State();
      ret.palette = palette.dup;
      ret.nextWellId = nextWellId;
      ret.nextTargetIndex = nextTargetIndex;
      ret.useColorCount = useColorCount;
      ret.colorDeltaSum = colorDeltaSum;
      ret.commands = commands.dup;
      return ret;
    }

    void newWell(int colorId) {
      palette[nextWellId] = Well(nextWellId, 1, OWN[colorId]);
      commands ~= "1 %s %s %s".format(nextWellId / N, nextWellId % N, colorId);
      nextWellId = (nextWellId + 1) % N;
      useColorCount++;
    }

    void addWell(int wellId, int colorId) {
      palette[wellId] = palette[wellId].add(1, OWN[colorId]);
      commands ~= "1 %s %s %s".format(wellId / N, wellId % N, colorId);
      useColorCount++;
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
      if (palette[bestWell].size <= 0.001) palette.remove(bestWell);
      nextTargetIndex++;
      colorDeltaSum += sqrt(bestDelta) - sqrt(3.0);
      commands ~= "2 %s %s".format(bestWell / N, bestWell % N);
    }

    double calcScore() {
      return 1
        + (useColorCount - H) * D 
        + colorDeltaSum * 10^^4
      ;
    }

    State[] simulateStep(bool addOnly = false) {
      State[] ret;
      if (!addOnly) foreach(i; 0..K) {
        auto state = this.dup();
        state.newWell(i);
        ret ~= state;
      }

      foreach(to; palette.keys) {
        foreach(i; 0..K) {
          auto state = this.dup();
          state.addWell(to, i);
          ret ~= state;
        }
      }
      return ret;
    }
  }
  
  foreach(target; TARGET) {
    int wi;
    double bestScore = int.max;
    foreach(times, tree; kdTree[1..$].enumerate(1)) {
      auto nearest = *(tree.nearest(target.asArray.kdPoint));
      auto nci = WCI[times][Color(nearest[0], nearest[1], nearest[2])];
      auto nc = WC[nci];

      auto score = target.delta(nc.color).sqrt * 10^^4;
      score += times * D;
      if (bestScore.chmin(score)) wi = nci;
    }
    
    auto wc = WC[wi];
    foreach(c; wc.colorIds) writefln("1 0 0 %s", c);
    writefln("2 0 0");
    foreach(_; 0..wc.colorIds.length - 1) writefln("3 0 0");
  }
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
