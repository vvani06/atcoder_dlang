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
      bool[] visited = new bool[](M);
      int routeSize = 1000;
      int[] order = M.iota.filter!(i => T[i][0] != A[sy][sx]).array;
      order = M.iota.filter!(i => T[i][0] == A[sy][sx]).array ~ order;

      foreach(i; order) {
        if (visited[i]) continue;

        int bestReduced = -1;
        int[] bestRoute;
        DList!int route;
        route.insertBack(i);
        visited[i] = true;

        void dfs(int cur, int reduced) {
          if (bestReduced.chmax(reduced)) {
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
        routes ~= bestRoute;
        routeSize -= bestReduced;
      }
    }

    Coord[][] coordsByChar = new Coord[][](100, 0);
    int[][][][] indiciesByCoordAndChar = new int[][][][](N, N, 100, 0);
    foreach(y; 0..N) foreach(x; 0..N) {
      coordsByChar[A[y][x]] ~= Coord(x, y);
    }

    foreach(y; 0..N) foreach(x; 0..N) {
      foreach(c; CHARS) {
        if (A[y][x] == c) continue;

        int dist(Coord co) { return abs(co.x - x) + abs(co.y - y); }
        indiciesByCoordAndChar[y][x][c] = coordsByChar[c].enumerate(0).array.sort!((a, b) => dist(a[1]) < dist(b[1])).map!"a[0]".array;
      }
    }

    int cost;
    int pre = -1;
    Coord cur = Coord(sx, sy);
    Coord[] ans;
    foreach(route; routes) foreach(ti; route) {
      auto t = pre == -1 ? T[ti] : T[ti][commonSize[pre][ti]..$];
      pre = ti;

      foreach(c; t) {
        auto nexts = indiciesByCoordAndChar[cur.y][cur.x][c];
        
        if (nexts.empty) {
          ans ~= cur;
          cost++;
        } else {
          auto next = coordsByChar[c][nexts[0]];
          ans ~= next;
          cost += abs(cur.x - next.x) + abs(cur.y - next.y) + 1;
          cur = next;
        }
      }
    }

    foreach(c; ans) {
      writefln("%d %d", c.y, c.x);
    }
    stderr.writeln(max(1001, 10000 - cost));
    ans.length.deb;
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
