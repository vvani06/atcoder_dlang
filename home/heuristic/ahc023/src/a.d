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
}

struct Plan {
  Crop crop;
  Coord coord;
  int month;

  string toString() { return "%s %s %s %s".format(crop.id + 1, coord.y, coord.x, month); }
}

void problem() {
  int T = scan!int;
  int H = scan!int;
  int W = scan!int;
  int I0 = scan!int;
  bool[][] BH = scan!string(H - 1).map!(s => s.map!"a == '1'".array).array;
  bool[][] BW = scan!string(H).map!(s => s.map!"a == '1'".array).array;
  int K = scan!int;
  SortedRange!(Crop[]) crops = (K.iota.map!(k => Crop(k, scan!int, scan!int)).array ~ Crop(0, 0)).sort;

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
    entry.set(using, T + 1);

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
      auto ord = new int[][](H, W);
      auto low = new int[][](H, W);
      auto used = using.map!"a.dup".array;
      bool[Coord] ret;

      int dfs(Coord cur, int k, Coord par) {
        cur.set(used, true);
        ord[cur.y][cur.x] = k++;
        low[cur.y][cur.x] = cur.of(ord);
        bool isAps = false;
        int count;

        foreach(to; cur.of(pathes)) {
          if (!to.of(used)) {
            count++;
            k = dfs(to, k, cur);
            cur.set(low, min(cur.of(low), to.of(low)));
            if (par != cur && cur.of(ord) <= to.of(low)) isAps = true;
            if (cur.of(ord) < to.of(low)) ret[cur] = true;
          } else if (par == to) {
            cur.set(low, min(cur.of(low), to.of(ord)));
          }
        }

        if (par == cur && count >= 2) isAps = true;
        if (isAps) ret[cur] = true;
        return k;
      }

      foreach(y; 0..H) foreach(x; 0..W) {
        int k;
        if (!used[y][x]) k = dfs(Coord(x, y), k, Coord(x, y));
      }
      return ret;
    }

    auto bridges = calcBridges();
    Plan[] plans;
    Crop[][] cropsByStartMonth = new Crop[][](T + 1, 0);
    foreach(crop; crops) {
      cropsByStartMonth[crop.start] ~= crop;
    }

    // int ci;
    foreach(month; 1..T + 1) {
      foreach(crop; cropsByStartMonth[month]) {
      // while(crops[ci].start >= month) {
        // auto crop = &crops[ci];
        if (crop.used) continue;

        () {
          foreach(d; iota(maxDistance, -1, -1)) foreach(c; coordsByDistance[d]) {
            if (c.of(using) || c in bridges) continue;

            bool isOk = true;
            foreach(around; c.of(pathes)) {
              if (around.of(using) > 0 && around.of(using) < crop.end) isOk = false;
            }

            if (isOk) {
              c.set(using, crop.end);
              plans ~= Plan(crop, c, month);
              crop.used = true;
              
              return;
            }
          }
        }();

        if (!crop.used) break;
      }

      for(auto queue = DList!Coord(entry.of(pathes)); !queue.empty;) {
        auto cur = queue.front; queue.removeFront;
        if (cur.of(using) > month) continue;

        cur.set(using, 0);
        foreach(next; cur.of(pathes)) {
          if (next.of(using) > month) continue;

          queue.insertBack(next);
        }

        break;
      }
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
