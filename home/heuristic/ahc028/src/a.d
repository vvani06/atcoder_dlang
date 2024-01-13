void main() { runSolver(); }

// ----------------------------------------------

struct Coord {
  int x, y;

  T of(T)(T[][] grid) { return grid[y][x]; }
  T set(T)(T[][] grid, T value) { return grid[y][x] = value; }
  int distance(Coord other) { return abs(x - other.x) + abs(y - other.y); }
  inout int id() { return y*100 + x; }
  inout int opCmp(inout Coord other) { return id == other.id ? 0 : id < other.id ? -1 : 1; }
}

void problem() {
  int N = scan!int;
  int M = scan!int;
  int L = 5;
  int sy = scan!int;
  int sx = scan!int;
  string[] A = scan!string(N);
  string[] T = scan!string(M);
  enum CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; 

  auto solve() {
    int[][] commonSize = new int[][](M, M);
    int[][] forwarders = new int[][](M, 0); {
      foreach(l; 1..L) {
        foreach(f; 0..M) foreach(t; 0..M) {
          if (f == t || commonSize[f][t] > 0) continue;

          string sf = T[f];
          string st = T[t];
          if (sf[l..L] == st[0..L - l]) {
            commonSize[f][t] = L - l;
            forwarders[f] ~= t;
          }
        }
      }
    }

    int[][] routes; {
      int bestReduced = -1;

      foreach(_; 0..1_000) {
        int[] order = M.iota.filter!(i => T[i][0] == A[sy][sx]).array.randomShuffle ~ M.iota.filter!(i => T[i][0] != A[sy][sx]).array.randomShuffle;
        int tryReduced = -1;
        int[][] tryRoutes;
        bool[] visited = new bool[](M);

        foreach(i; order) {
          if (visited[i]) continue;

          int[] bestRoute;
          DList!int route;
          route.insertBack(i);
          visited[i] = true;

          void dfs(int cur, int reduced) {
            if (tryReduced.chmax(reduced)) {
              bestRoute = route.array;
            }
            
            foreach(next; forwarders[cur].filter!(n => !visited[n])) {
              route.insertBack(next);
              visited[next] = true;
              dfs(next, reduced + commonSize[cur][next]);
              // route.removeBack();
              // visited[next] = false;
              break;
            }
          }

          dfs(i, 0);
          // bestRoute.deb;
          // [[bestRoute.length, bestReduced]].deb;
          tryRoutes ~= route.array;
        }

        if (bestReduced.chmax(tryReduced)) {
          routes = tryRoutes;
        }
      }
    }

    Coord[][] coordsByChar = new Coord[][](100, 0);
    int[][][][] indiciesByCoordAndChar = new int[][][][](N, N, 100, 0);
    foreach(y; 0..N) foreach(x; 0..N) {
      coordsByChar[A[y][x]] ~= Coord(x, y);
    }

    foreach(y; 0..N) foreach(x; 0..N) {
      foreach(c; CHARS) {
        if (A[y][x] == c) {
          foreach(i, co; coordsByChar[c]) {
            if (co.x == x && co.y == y) {
              indiciesByCoordAndChar[y][x][c] ~= i.to!int;
              break;
            }
          }
          continue;
        }

        int dist(Coord co) { return abs(co.x - x) + abs(co.y - y); }
        indiciesByCoordAndChar[y][x][c] = coordsByChar[c].enumerate(0).array.sort!((a, b) => dist(a[1]) < dist(b[1])).map!"a[0]".array;
      }
    }

    int cost;
    int pre = -1;
    Coord cur = Coord(sx, sy);
    Coord[] ans;

    auto candidates = routes.length.to!int.iota.redBlackTree;
    int nextRouteIndex = 0;

    string finalRoute; 
    while(!candidates.empty) {
      candidates.removeKey(nextRouteIndex);

      foreach(ti; routes[nextRouteIndex]) {
        auto t = pre == -1 ? T[ti] : T[ti][commonSize[pre][ti]..$];
        pre = ti;

        foreach(c; t) {
          auto nexts = indiciesByCoordAndChar[cur.y][cur.x][c];
          auto next = coordsByChar[c][nexts[0]];
          ans ~= next;
          cost += abs(cur.x - next.x) + abs(cur.y - next.y) + 1;
          cur = next;
          finalRoute ~= c;
        }
      
        int bestDistance = int.max;
        foreach(nextRoute; candidates.array) {
          auto c = T[routes[nextRoute][0]][0];
          auto nearest = indiciesByCoordAndChar[cur.y][cur.x][c][0];
          if (bestDistance.chmin(cur.distance(coordsByChar[c][nearest]))) {
            nextRouteIndex = nextRoute;
          }
        }
      }
    }

    alias Item = Tuple!(int, "cost", Coord, "from");
    auto dp = new Item[Coord][](finalRoute.length);
    dp[0][Coord(sx, sy)] = Item(1, Coord(sx, sy));
    foreach(i, c; finalRoute[1..$].enumerate(1)) {
      foreach(from, v; dp[i - 1]) {
        foreach(to; coordsByChar[c]) {
          auto dist = from.distance(to);
          auto newCost = v.cost + dist + 1;
          if (!(to in dp[i]) || dp[i][to].cost.chmin(newCost)) {
            dp[i][to] = Item(newCost, from);
          }
        }
      }
    }

    Coord[] dpAns;
    Coord trace = dp[$ - 1].keys.minElement!(c => dp[$ - 1][c].cost);
    dpAns ~= trace;
    foreach_reverse(d; dp[1..$]) {
      trace = d[trace].from;
      dpAns ~= trace;
    }

    foreach(c; dpAns.reverse) {
      writefln("%d %d", c.y, c.x);
    }
    stderr.writeln(max(1001, 10000 - dp[$ - 1].values.map!"a.cost".minElement));
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
