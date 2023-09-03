void main() { runSolver(); }

// ----------------------------------------------

void problem() {
  auto D = scan!int;
  auto N = scan!int;
  auto R = scan!int(2 * N).chunks(2);
  auto ITEMS = D^^2 - 1 - N;

  alias Coord = Tuple!(int, "x", int, "y");
  auto EXIT = Coord(0, D / 2);

  auto solve() {
    auto distances = new int[][](D, D);
    auto coordsByDistance = new Coord[][](D ^^ 2, 0);

    foreach(ref d; distances) d[] = -1;
    foreach(r; R) distances[r[0]][r[1]] = -2;
    distances[EXIT.x][EXIT.y] = 0;

    for(auto queue = DList!Coord(EXIT); !queue.empty;) {
      auto p = queue.front; queue.removeFront;

      foreach(dx, dy; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
        auto x = p.x + dx;
        auto y = p.y + dy;
        if (min(x, y) < 0 || max(x, y) >= D) continue;

        if (distances[x][y] == -1) {
          distances[x][y] = distances[p.x][p.y] + 1;
          coordsByDistance[distances[x][y]] ~= Coord(x, y);
          queue.insert(Coord(x, y));
        }
      }
    }

    auto idealDistances = new int[](ITEMS); {
      int d, i;
      foreach(n; 0..ITEMS) {
        while(coordsByDistance[d].length <= i) {
          d++;
          i = 0;
        }
        idealDistances[n] = d;
        i++;
      }
    }

    auto coordByItems = new Coord[](ITEMS);
    auto items = new int[][](D, D); {
      foreach(ref d; items) d[] = -1;
      foreach(r; R) items[r[0]][r[1]] = -2;
      int rest = ITEMS;

      bool isBridge(Coord c) {
        auto visited = new bool[][](D, D);
        int r = rest;
        visited[c.x][c.y] = true;
        
        for(auto queue = DList!Coord(EXIT); !queue.empty;) {
          auto p = queue.front; queue.removeFront;
          if (visited[p.x][p.y]) continue;

          visited[p.x][p.y] = true;
          r--;

          foreach(dx, dy; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
            auto x = p.x + dx;
            auto y = p.y + dy;
            if (min(x, y) < 0 || max(x, y) >= D || visited[x][y]) continue;

            if (items[x][y] == -1) {
              queue.insert(Coord(x, y));
            }
          }
        }

        return r != 0;
      }

      auto curDist = distances.map!(a => a.filter!"a > 0".maxElement).maxElement;
      auto coordsQueue = coordsByDistance.map!(a => DList!Coord(a)).array;
      foreach(i; 0..ITEMS) {
        auto itemId = scan!int;
        auto idealDist = idealDistances[itemId];
        auto used = new bool[][](D, D);

        foreach(dist; iota(idealDist, coordsByDistance.length.to!int).array ~ iota(0, idealDist).array.reverse.array) {
          bool isOk;
          foreach(c; coordsByDistance[dist].randomShuffle) {
            if (used[c.x][c.y] || isBridge(c)) continue;

            used[c.x][c.y] = true;
            coordByItems[itemId] = c;
            items[c.x][c.y] = itemId;
            writefln("%s %s", c.x, c.y);
            stdout.flush;
            isOk = true;
            break;
          }
          if (isOk) break;
        }
        rest--;
      }
    }

    "----------".deb;

    // auto visited = new bool[][](D, D);
    // auto availableItems = new int[](0).redBlackTree;
    // int[] search(Coord start) {
    //   bool[int] ret;
    //   for(auto queue = DList!Coord(start); !queue.empty;) {
    //     auto p = queue.front; queue.removeFront;
    //     visited[p.x][p.y] = true;

    //     foreach(dx, dy; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
    //       auto x = p.x + dx;
    //       auto y = p.y + dy;
    //       if (min(x, y) < 0 || max(x, y) >= D || visited[x][y]) continue;

    //       const item = items[x][y];
    //       if (item == -1) {
    //         queue.insert(Coord(x, y));
    //       } else if (item != -2 && !(item in availableItems)) {
    //         ret[item] = true;
    //       }
    //     }
    //   }
    //   return ret.keys;
    // }

    // long calcScore(int itemId, int[] items) {
    //   return itemId^^2 + (items.empty ? 100 : items.minElement) ^^ 2;
    // }

    // availableItems.insert(search(EXIT));
    // availableItems.deb;
    // while(!availableItems.empty) {
    //   int bestItemId;
    //   long bestScore = long.max;
    //   foreach(itemId; availableItems.array) {
    //     auto detected = search(coordByItems[itemId]);
    //     if (bestScore.chmin(calcScore(itemId, detected))) bestItemId = itemId;
    //   }

    //   auto c = coordByItems[bestItemId];
    //   availableItems.removeKey(bestItemId);
    //   writefln("%s %s", c.x, c.y);
    //   stdout.flush;

    //   items[c.x][c.y] = -1;
    //   availableItems.insert(search(c));
    // }

    auto availableItems = ITEMS.iota.redBlackTree;
    enum INF = long.max / 3;
    while(!availableItems.empty) {
      auto target = availableItems.front;
      auto targetCoord = coordByItems[target];
      
      alias QueueItem = Tuple!(long, "cost", int, "x", int, "y", int[], "route");
      auto from = new QueueItem[][](D, D);
      foreach(ref f; from) foreach(ref ff; f) ff.cost = INF;
      from[EXIT.x][EXIT.y].cost = 0;
      for(auto queue = [QueueItem(0, EXIT.x, EXIT.y, [])].heapify!"a.cost > b.cost"; !queue.empty;) {
        auto p = queue.front;
        queue.removeFront;
        if (p.x == targetCoord.x && p.y == targetCoord.y) break;
        if (from[p.x][p.y].cost != p.cost) continue;

        foreach(dx, dy; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
          auto x = p.x + dx;
          auto y = p.y + dy;
          if (min(x, y) < 0 || max(x, y) >= D || from[x][y].cost != INF) continue;

          auto item = items[x][y];
          if (item == -2) continue;

          long newCost = p.cost;
          int[] newRoute = p.route.dup;
          if (item >= 0){
            auto avi = availableItems.dup;
            avi.removeKey(p.route);
            newCost += avi.lowerBound(item).array.length;
            newRoute ~= item;
          }

          auto qi = QueueItem(newCost, x, y, newRoute);
          queue.insert(qi);
          from[x][y] = qi;
        }
      }
      
      // from[targetCoord.x][targetCoord.y].deb;
      foreach(r; from[targetCoord.x][targetCoord.y].route) {
        availableItems.removeKey(r);
        auto c = coordByItems[r];
        items[c.x][c.y] = -1;
        writefln("%s %s", c.x, c.y);
        stdout.flush();
      }
    }

    "FIN".deb;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
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
