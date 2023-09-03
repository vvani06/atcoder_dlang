void main() { runSolver(); }

// ----------------------------------------------

struct Crop {
  int id, start, end;
  bool used;

  int score() { return end - start + 1; }
  int opCmp(Crop other) { 
    if (end > other.end) return -1;
    if (end < other.end) return 1;
    return start < other.start ? -1 : start > other.start ? 1 : 0;
  }
}

struct Coord {
  int x, y;

  T of(T)(T[][] grid) { return grid[y][x]; }
  T set(T)(T[][] grid, T value) { return grid[y][x] = value; }
  int id() { return y*20 + x; }
}

struct Plan {
  Crop crop;
  Coord coord;
  int month;

  string toString() { return "%s %s %s %s".format(crop.id, coord.y, coord.x, month); }
}

void problem() {
  int T = scan!int;
  int H = scan!int;
  int W = scan!int;
  int I0 = scan!int;
  bool[][] BH = scan!string(H - 1).map!(s => s.map!"a == '1'".array).array;
  bool[][] BW = scan!string(H).map!(s => s.map!"a == '1'".array).array;
  int K = scan!int;
  SortedRange!(Crop[]) crops = K.iota.map!(k => Crop(k + 1, scan!int, scan!int)).array.sort;

  auto solve() {
    Coord[][][] pathes = new Coord[][][](H, W, 0);
    foreach(y, bh; BH.enumerate(1)) foreach(x, b; bh.enumerate(0).filter!"a[1] == 0") {
      pathes[y - 1][x] ~= Coord(x, y);
      pathes[y][x] ~= Coord(x, y - 1);
    }
    foreach(y, bw; BW.enumerate(0)) foreach(x, b; bw.enumerate(1).filter!"a[1] == 0") {
      pathes[y][x - 1] ~= Coord(x, y);
      pathes[y][x] ~= Coord(x - 1, y);
    }
    
    auto entry = Coord(0, I0);

    int[][] distances = H.iota.map!(_ => int.max.repeat(W).array).array;
    int maxDistance;
    Coord[][] coordsByDistance = new Coord[][](H * W, 0);
    entry.set(distances, 0);
    for(auto queue = DList!Coord(entry); !queue.empty;) {
      auto p = queue.front; queue.removeFront;
      coordsByDistance[p.of(distances)] ~= p;

      foreach(next; p.of(pathes)) {
        if (next.of(distances) != int.max) continue;

        const d = p.of(distances) + 1;
        next.set(distances, d);
        maxDistance = max(maxDistance, d);
        queue.insertBack(next);
      }
    }
    coordsByDistance.length = maxDistance + 1;

    int[][] using = new int[][](H, W);

    bool isBridge(Coord spot) {
      auto visited = using.map!"a.dup".array;
      spot.set(visited, 1);
      for(auto queue = DList!Coord(spot.of(pathes)); !queue.empty;) {
        auto cur = queue.front; queue.removeFront;
        cur.set(visited, 1);

        foreach(next; cur.of(pathes)) {
          if (next.of(visited) > 0) continue;

          queue.insertBack(next);
          next.set(visited, 1);
        }
      }

      return visited.any!"a.canFind(0)";
    }

    bool[Coord] calcBridges() {
      auto ord = new int[](H * W);
      auto low = new int[](H * W);
      auto used = using.map!"a.dup".array;
      bool[Coord] ret;

      ord[] = H * W + 1;
      low[] = H * W + 1;

      int dfs(Coord cur, int k, Coord par) {
        cur.set(used, true);
        ord[cur.id] = k;
        low[cur.id] = k++;
        bool isAps = false;
        int count;

        foreach(to; cur.of(pathes)) {
          if (!to.of(used)) {
            count++;
            k = dfs(to, k, cur);
            low[cur.id].chmin(low[to.id]);
            if (par != cur && ord[cur.id] <= low[to.id]) isAps = true;
            if (ord[cur.id] < low[to.id]) ret[cur] = true;
          } else if (par != to) {
            low[cur.id].chmin(ord[to.id]);
          }
        }

        if (par == cur && count >= 2) isAps = true;
        if (isAps) ret[cur] = true;
        return k;
      }
      
      // int k = 0;
      // foreach(y; 0..H) foreach(x; 0..W) {
      //   auto c = Coord(x, y);
      //   if (!c.of(used)) k = dfs(c, k, c);
      // }
      dfs(entry, 0, entry);
      // low.chunks(W).map!(u => "%(%03d %)".format(u)).each!deb;
      return ret;
    }

    auto bridges = calcBridges();
    // bridges.keys.sort!"a.id < b.id".each!deb;

    Plan[] plans;
    Crop[][] cropsByStartMonth = new Crop[][](T + 1, 0);
    foreach(crop; crops) {
      cropsByStartMonth[crop.start] ~= crop;
    }

    // int ci;
    foreach(month; 1..T + 1) {
      deb("month: ", month);
      // using.map!(u => "%(%03d %)".format(u)).each!deb;
      // bridges.keys.sort!"a.id < b.id".each!deb;
      // cropsByStartMonth[month].deb;
      int planted;
      int allScore, earnedScore;
      foreach(crop; cropsByStartMonth[month]) {
        () {
          foreach(d; iota(maxDistance, 0, -1)) foreach(c; coordsByDistance[d]) {
            if (c.of(using) || c in bridges) continue;

            bool isOk = true;
            foreach(around; c.of(pathes)) {
              if (around.of(using) > 0 && around.of(using) < crop.end) isOk = false;
            }

            if (isOk) {
              // deb(crop, c);
              c.set(using, crop.end);
              plans ~= Plan(crop, c, month);
              bridges = calcBridges();
              planted++;
              crop.used = true;
              return;
            }
          }
        }();

        allScore += crop.score;
        if (crop.used) earnedScore += crop.score;
      }

      const ratio = allScore == 0 ? 100 : earnedScore * 100 / allScore;
      "[%05d / %05d] (%06d / %06d) %d%%".format(planted, cropsByStartMonth[month].length, earnedScore, allScore, ratio).deb;

      auto visited = new bool[][](H, W);
      for(auto queue = DList!Coord(entry); !queue.empty;) {
        auto cur = queue.front; queue.removeFront;
        if (cur.of(using) > month) continue;

        cur.set(visited, true);
        if (cur.of(using) > 0) cur.set(using, 0);

        foreach(next; cur.of(pathes)) {
          if (next.of(visited) || next.of(using) > month) continue;

          queue.insertBack(next);
          next.set(visited, true);
        }
      }
      bridges = calcBridges();
    }

    plans.length.writeln;
    plans.each!writeln;
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
