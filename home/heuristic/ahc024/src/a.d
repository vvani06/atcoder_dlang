void main() { runSolver(); }

// ----------------------------------------------

struct Coord {
  int x, y;

  T of(T)(T[][] grid) { return grid[y][x]; }
  T set(T)(T[][] grid, T value) { return grid[y][x] = value; }
  inout int id() { return y*100 + x; }
  inout int opCmp(inout Coord other) { return id == other.id ? 0 : id < other.id ? -1 : 1; }
}

enum AROUND = zip([0, -1, 0, 1], [-1, 0, 1, 0]);

void problem() {
  int N = scan!int;
  int M = scan!int;
  int[][] C = 0.repeat(N + 2).array ~ scan!int(N ^^ 2).chunks(N).map!(c => 0 ~ c ~ 0).array ~ 0.repeat(N + 2).array;

  auto solve() {
    auto coordsByColor = (M + 1).iota.map!(_ => new Coord[](0).redBlackTree).array;
    auto graph = new bool[][](M + 1, M + 1);
    foreach(m; 0..M + 1) graph[m][m] = true;
    foreach(y; 1..N + 1) foreach(x; 1..N + 1)  {
      const base = C[y][x];
      coordsByColor[base].insert(Coord(x, y));
      foreach(dx, dy; AROUND) {
        auto ax = x + dx;
        auto ay = y + dy;
        auto other = C[ay][ax];
        if (other != base) {
          graph[base][other] = true;
          graph[other][base] = true;
        }
      }
    }

    auto graphArr = new int[][](M + 1, 0);
    foreach(f; 0..M) foreach(t; f + 1..M + 1) {
      if (graph[f][t]) {
        graphArr[f] ~= t;
        graphArr[t] ~= f;
      }
    }

    auto distsToZero = new int[](M + 1); {
      for(auto queue = DList!int(0); !queue.empty;) {
        auto from = queue.front; queue.removeFront;
        foreach(to; graph[from].enumerate(0).filter!"a[1]".map!"a[0]") {
          if (to == 0 || distsToZero[to] != 0) continue;

          queue.insertBack(to);
          distsToZero[to] = distsToZero[from] + 1;
        } 
      }
    }

    auto distScores = new int[](M + 1);
    foreach(m; 1..M + 1) {
      distScores[m] += distsToZero[m]^^7;
      distScores[m] += graphArr[m].map!(a => distsToZero[a]).sum;
    }
    foreach(g; graphArr) g.sort!((a, b) => distScores[a] > distScores[b]);

    distScores.enumerate(0).array.sort!"a[1] > b[1]".each!deb;

    // LowLink による関節点検出 O(E + V)
    bool[Coord] calcBridges(ref int[][] grid, Coord from, int color) {
      bool[Coord] ret;
      if (from.of(grid) != color) return ret;
      
      auto ord = new int[]((N + 2)^^2);
      auto low = new int[]((N + 2)^^2);
      auto visited = new bool[][](N + 2, N + 2);

      ord[] = (N + 2)^^2 + 1;
      low[] = (N + 2)^^2 + 1;

      int dfs(Coord cur, int k, Coord par) {
        cur.set(visited, true);
        ord[cur.id] = k;
        low[cur.id] = k++;
        bool isAps = false;
        int count;

        foreach(dx, dy; AROUND) {
          auto to = Coord(from.x + dx, from.y + dy);
          if (to.of(grid) == color) {
            if (!to.of(visited)) {
              count++;
              k = dfs(to, k, cur);
              low[cur.id].chmin(low[to.id]);
              if (par != cur && ord[cur.id] <= low[to.id]) isAps = true;
              if (ord[cur.id] < low[to.id]) ret[cur] = true;
            } else if (par != to) {
              low[cur.id].chmin(ord[to.id]);
            }
          }
        }

        if (par == cur && count >= 2) isAps = true;
        if (isAps) ret[cur] = true;
        return k;
      }

      dfs(from, 0, from);
      return ret;
    }
    // graph.enumerate(0).each!(a => "%03d : %(%03d %)".format(a[0], a[1]).deb);


    bool canFill(Coord from, int colorTo) {
      // 元の色が連結しなくなる or 区の関係がみだれる で false
      auto colorFrom = from.of(C);
      if (!graph[colorFrom][colorTo]) return false;

      auto toVisit = coordsByColor[colorFrom].dup;
      toVisit.removeKey(from);
      if (!graph[colorFrom][colorTo]) return false;

      DList!Coord queue;
      bool aroundContainsTo;
      foreach(dx, dy; AROUND) {
        auto coord = Coord(from.x + dx, from.y + dy);
        auto color = coord.of(C);

        if (color == colorFrom) {
          if (queue.empty) {
            queue.insertBack(coord);
            toVisit.removeKey(coord);
          }
        } else {
          if (color == colorTo) aroundContainsTo = true;
          if (!graph[color][colorTo]) return false;
        }
      }

      if (!aroundContainsTo) return false;

      auto rel = new bool[](M + 1);
      rel[colorFrom] = true;
      while(!queue.empty) {
        auto f = queue.front; queue.removeFront;
        foreach(dx, dy; AROUND) {
          auto t = Coord(f.x + dx, f.y + dy);
          if (t in toVisit) {
            queue.insertBack(t);
            toVisit.removeKey(t);
          } else if (t != from) {
            rel[t.of(C)] = true;
          }
        }
      }

      // toVisit.deb;
      // rel.enumerate(0).filter!"a[1]".map!"a[0]".deb;
      return toVisit.empty && rel == graph[colorFrom];
    }

    void fill(Coord from, int colorTo) {
      auto colorFrom = from.of(C);
      from.set(C, colorTo);
      coordsByColor[colorFrom].removeKey(from);
      coordsByColor[colorTo].insert(from);
    }

    auto searchCoords = new Coord[][](N);
    foreach(y; 1..N + 1) foreach(x; 1..N + 1) {
      auto d = max(abs(x - (N + 2) / 2), abs(y - (N + 2) / 2));
      searchCoords[d] ~= Coord(x, y);
    }
    
    foreach_reverse(coords; searchCoords) {
      foreach(coord; coords) {
        if (canFill(coord, 0)) {
          fill(coord, 0);
        }
      }
    }
    
    foreach(fromColor; distScores.enumerate(0).array.sort!"a[1] > b[1]".map!"a[0]") {
      if (fromColor == 0) break;

      auto outerNeighbors = new int[](0);
      foreach(neighborColor; graphArr[fromColor]) {
        if (distScores[fromColor] > distScores[neighborColor]) outerNeighbors ~= neighborColor;
      }

      while(true) {
        bool filledAny;
        foreach(coord; coordsByColor[fromColor].array) {
          foreach(neighborColor; outerNeighbors) {
            // deb(fromColor, " / ", neighborColor, " / ", coord);
            if (canFill(coord, neighborColor)) {
              fill(coord, neighborColor);
              filledAny = true;
              break;
            }
          }
        }

        if (!filledAny) break;
      }
    }
    
    foreach_reverse(coords; searchCoords) {
      foreach(coord; coords) {
        if (canFill(coord, 0)) {
          fill(coord, 0);
        }
      }
    }

    foreach(c; C[1..$ - 1]) writefln("%(%s %)", c[1..$ - 1]);
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
