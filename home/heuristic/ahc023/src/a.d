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
  inout int id() { return y*20 + x; }
  inout int opCmp(inout Coord other) { return id == other.id ? 0 : id < other.id ? -1 : 1; }
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

    byte[][] numPathes = new byte[][](W, H);
    foreach(y; 0..H) foreach(x; 0..W) numPathes[y][x] = pathes[y][x].length.to!byte;
    foreach(ref cs; coordsByDistance) cs.sort!((a, b) => a.of(numPathes) < b.of(numPathes));

    auto coordsByPathes = new Coord[][](5, 0);
    foreach(y; 0..H) foreach(x; 0..W) coordsByPathes[numPathes[y][x]] ~= Coord(x, y);
    foreach(c; coordsByPathes) c.sort!((a, b) => a.of(distances) > b.of(distances));

    int[][] using = new int[][](H, W);
    auto useSets = (T + 1).iota.map!(_ => new Coord[](0).redBlackTree).array;

    void use(Coord c, int e) {
      if (c.of(using) != 0) assert("double farming");

      useSets[e].insert(c);
      c.set(using, e);
      foreach(around; c.of(pathes)) numPathes[around.y][around.x]--;
      // foreach(ref cs; coordsByDistance) cs.sort!((a, b) => a.of(numPathes) < b.of(numPathes));
    }

    void harvest(Coord c) {
      if (c.of(using) == 0) assert("no crop");

      useSets[c.of(using)].removeKey(c);
      c.set(using, 0);
      foreach(around; c.of(pathes)) numPathes[around.y][around.x]++;
      // foreach(ref cs; coordsByDistance) cs.sort!((a, b) => a.of(numPathes) < b.of(numPathes));
    }

    // LowLink による関節点検出 O(E + V)
    bool[Coord] calcBridges() {
      auto ord = new int[](H * W);
      auto low = new int[](H * W);
      auto used = using.map!"a.dup".array;
      bool[Coord] ret = [entry: true];

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

    Plan[] plans;
    Crop[][] cropsByStartMonth = new Crop[][](T + 1, 0);
    foreach(crop; crops) {
      cropsByStartMonth[crop.start] ~= crop;
    }

    auto bridges = calcBridges();
    // bridges.keys.sort!"a.id < b.id".each!deb;

    bool canSet(Coord c, int e) {
      if (c.of(using) || c in bridges) return false;

      bool isOk = true;
      foreach(around; c.of(pathes)) {
        if (!isOk) break;

        () {
          if (e <= around.of(using)) return;

          bool[int] visited;
          visited[c.id] = true;
          int accesableMinimum(Coord a) {
            visited[a.id] = true;
            auto ret = a.of(using);
            if (ret == 0) return ret;

            foreach(next; a.of(pathes)) {
              if (next.id in visited) continue;

              visited[next.id] = true;
              if (next.of(using) <= ret) ret = min(ret, accesableMinimum(next));
            }
            return ret;
          }
          if (accesableMinimum(around) > 0) isOk = false;
        }();
      }
      return isOk;
    }

    foreach(month; 1..T + 1) {
      deb("month: ", month);
      // using.map!(u => "%(%03d %)".format(u)).each!deb;
      // bridges.keys.sort!"a.id < b.id".each!deb;
      // cropsByStartMonth[month].deb;
      int planted;
      int allScore, earnedScore;
      foreach(ref crop; cropsByStartMonth[month]) {
        () {
          foreach(d; crop.end..min(T, crop.end + 3)) {
            foreach(u; useSets[d]) {
              foreach(c; u.of(pathes)) {
                if (!canSet(c, crop.end)) continue;

                use(c, crop.end);
                plans ~= Plan(crop, c, month);
                bridges = calcBridges();
                planted++;
                crop.used = true;
                return;
              }
            }
          }

          foreach(cs; coordsByPathes) {
            foreach(c; cs) {
              if (!canSet(c, crop.end)) continue;

              use(c, crop.end);
              plans ~= Plan(crop, c, month);
              bridges = calcBridges();
              planted++;
              crop.used = true;
              return;
            }
          }

          // int[] dd; {
          //   auto base = min(maxDistance, (crop.end - month) * 3);
          //   dd ~= base;
          //   foreach(d; 1..maxDistance) {
          //     if (base + d <= maxDistance) dd ~= base + d;
          //     if (base - d >= 1) dd ~= base - d;
          //   }
          // }
          // auto dd = iota(maxDistance, 0, -1);
          auto dd = iota(1, maxDistance + 1);
          foreach(d; dd) foreach(c; coordsByDistance[d]) {
            if (c.of(using) || c in bridges) continue;

            bool isOk = true;
            foreach(around; c.of(pathes)) {
              () {
                if (crop.end <= around.of(using)) return;

                bool[int] visited;
                visited[c.id] = true;
                int accesableMinimum(Coord a, Coord pre) {
                  visited[a.id] = true;
                  auto ret = a.of(using);
                  if (ret == 0) return ret;

                  foreach(next; a.of(pathes)) {
                    if (next.id in visited) continue;

                    visited[next.id] = true;
                    if (next.of(using) <= ret) ret = min(ret, accesableMinimum(next, a));
                  }
                  return ret;
                }
                // if (!around.of(pathes).filter!(a => a != c).any!(a => a.of(using) == 0)) isOk = false;
                if (accesableMinimum(around, around) > 0) isOk = false;
              }();
              
              if (!isOk) break;
            }

            if (isOk) {
              // deb(crop, c);
              // c.set(using, crop.end);
              use(c, crop.end);
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
      cropsByStartMonth[month].filter!"!a.used".each!deb;

      auto visited = new bool[][](H, W);
      for(auto queue = DList!Coord(entry); !queue.empty;) {
        auto cur = queue.front; queue.removeFront;
        if (cur.of(using) > month) continue;

        cur.set(visited, true);
        if (cur.of(using) > 0) {
          // cur.set(using, 0);
          harvest(cur);
        }

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
