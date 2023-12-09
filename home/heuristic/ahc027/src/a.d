void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  int N = scan!int;
  int id(int y, int x) { return y + x * N; }

  string[] H = scan!string(N - 1);
  string[] V = scan!string(N);
  long[] DR = scan!long(N * N);
  long[] D = (N * N).iota.map!(i => DR[id(i / N, i % N)]).array;

  enum LEFT = 0;
  enum UP = 1;
  enum RIGHT = 2;
  enum DOWN = 3;
  enum DIRS = "LURD";

  struct Path {
    int to, dir;
  }

  long calcScore(string route) {
    auto rn = route.length.to!int;
    auto visits = (N * N).iota.map!(_ => new int[](0).redBlackTree).array;
    int pre;
    foreach(i, d; route) {
      visits[pre].insert(i.to!int);
      
      if (d == DIRS[LEFT]) pre-=N;
      if (d == DIRS[RIGHT]) pre+=N;
      if (d == DIRS[UP]) pre--;
      if (d == DIRS[DOWN]) pre++;
    }
    visits[0].insert(rn);

    // long[] avgA = new long[](N * N);
    long ret;
    foreach(i; 0..N * N) {
      int pret = visits[i].back - rn;
      foreach(t; visits[i].array ~ rn) {
        auto span = t - pret;
        if (pret < 0) {
          ret += D[i] * -pret * t;
          ret += D[i] * t * (t - 1) / 2;
        } else {
          ret += D[i] * span * (span - 1) / 2;
        }
        pret = t;
      }
    }

    return ret / rn;
  }

  auto solve() {
    Path[][] graph = new Path[][](N * N, 0);
    foreach(y; 0..N - 1) foreach(x; 0..N) {
      if (H[y][x] == '0') {
        graph[id(y, x)] ~= Path(id(y + 1, x), DOWN);
        graph[id(y + 1, x)] ~= Path(id(y, x), UP);
      }
    }
    foreach(y; 0..N) foreach(x; 0..N - 1) {
      if (V[y][x] == '0') {
        graph[id(y, x)] ~= Path(id(y, x + 1), RIGHT);
        graph[id(y, x + 1)] ~= Path(id(y, x), LEFT);
      }
    }

    auto visited = new bool[](N * N);
    Tuple!(string, int) bfsSet(int from, RedBlackTree!int toSet, bool dryRun = false) {
      string ret;
      Path[] froms = Path(-1, -1).repeat(N * N).array;
      froms[from] = Path(0, 0);

      int goal;
      for(auto queue = DList!int(from); !queue.empty;) {
        auto cur = queue.front; queue.removeFront;
        if (cur in toSet) {
          goal = cur;
          break;
        }

        foreach(next; graph[cur]) {
          if (froms[next.to].to != -1) continue;

          froms[next.to] = Path(cur, next.dir);
          queue.insert(next.to);
        }
      }

      for(auto cur = goal; cur != from; cur = froms[cur].to) {
        if (!dryRun) visited[cur] = true;
        ret ~= DIRS[froms[cur].dir];
      }
      if (!dryRun) visited[from] = true;

      // ret.retro.to!string.deb;
      return tuple(ret.retro.to!string, goal);
    }
    Tuple!(string, int) bfs(int from, int to, bool dryRun = false) {
      return bfsSet(from, [to].redBlackTree, dryRun);
    }

    string ans;
    int pre;
    foreach(y; 0..N) foreach(x; y % 2 == 0 ? N.iota.array : N.iota.retro.array) {
      if (pre == id(y, x)) continue;
      if (visited[id(y, x)]) continue;

      ans ~= bfs(pre, id(y, x))[0];
      pre = id(y, x);
    }

    auto ranked = D.enumerate(0).array.sort!"a[1] > b[1]";
    auto toVisits = ranked[0..$ / 8].map!"a[0]".redBlackTree;
    foreach(r; toVisits) visited[r] = false;

    while(!toVisits.empty) {
      auto route = bfsSet(pre, toVisits);
      ans ~= route[0];
      pre = route[1];
      toVisits.removeKey(pre);
      foreach(t; toVisits.array) {
        if (visited[t]) toVisits.removeKey(t);
      }
    }

    ans ~= bfs(pre, 0)[0];
    calcScore(ans).deb;
    ans.writeln;
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
