void main() { runSolver(); }

// ----------------------------------------------

enum int GU = 80;
enum AROUND = [[-1,0], [0,-1], [1,0], [0,1]];
enum GAROUND = [-1, -GU, 1, GU];
enum RAROUND = "LURD";
enum WALKS = ['L': -1, 'U':-GU, 'R': 1, 'D': GU];
int gn(int x, int y) { return GU*y + x; }

// ---------------------------------------------

struct Intersection {
  int p;
  bool[int] viewables;
  bool goal;
  int score;

  this(int p, int[] viewables, int score) {
    this.p = p;
    this.score = score;
    foreach(v; viewables) this.viewables[v] = true;
  }

  this(bool goal) {
    this.goal = goal;
  }

  bool remove(int[] vs, int[] costs) {
    if (goal) return false;

    foreach(i, v; vs) {
      viewables.remove(v);
      score -= costs[i];
    }
    return viewables.empty;
  }
}

struct Grid {
  int[][] g;
  int size;
  Intersection[int] inters;
  bool[int] viewed;

  int at(int p) { return g[p/GU][p%GU]; }
  int at(int x, int y) { return g[y][x]; }
  
  this(int size, string[] map) {
    g = new int[][](size, size);
    this.size = size;
    foreach(y; 0..size) foreach(x; 0..size) {
      if (map[y][x] != '#') g[y][x] = map[y][x] - '0';
    }

    foreach(y; 0..size) foreach(x; 0..size) {
      if (g[y][x] == 0) continue;
      const gp = gn(x, y);

      bool[] score = new bool[](4);
      static foreach(i, a; AROUND) {{
        const ax = x + a[0];
        const ay = y + a[1];
        if (ax >= 0 && ay >= 0 && ax < size && ay < size && map[ay][ax] != '#') score[i] = true;
      }}

      const sc = score.count(true);
      if (sc < 2) continue;
      if (sc == 2 && score[0] == true && score[2] == true) continue;
      if (sc == 2 && score[1] == true && score[3] == true) continue;

      auto vs = viewables(gp);
      inters[gp] = Intersection(gp, vs, vs.map!(v => at(v)).sum);
    }
  }

  void removeIntersection(int p) {
    if (!(p in inters)) return;

    auto inter = inters[p];
    inters.remove(p);

    auto vs = inter.viewables.keys;
    auto costs = vs.map!(v => at(v)).array;

    foreach(ip; inters.keys) {
      if (inters[ip].remove(vs, costs)) inters.remove(ip);
    }

    foreach(v; vs) viewed[v] = true;
  }

  int[] viewables(int p) {
    int[] ret = [p];
    static foreach(a; AROUND) {{
      int x = p%GU;
      int y = p/GU;
      while(true) {
        x += a[0];
        y += a[1];
        if (x >= 0 && y >= 0 && x < size && y < size && g[y][x] > 0) {
          ret ~= gn(x, y);
        } else {
          break;
        }
      }
    }}
    return ret;
  }
}

void problem() {
  auto N = scan!int;
  auto SY = scan!int;
  auto SX = scan!int;
  auto MAP = scan!string(N);

  auto solve() {
    auto G = Grid(N, MAP);

    auto cur = gn(SX, SY);
    string ans;
    while(!G.inters.empty) {
      string route;
      bool[int] visited = [cur: true];
      int dfs(int p, int pre, int cost) {
        cost += G.g[p%GU][p/GU];
        // [p%GU, p/GU].deb;
        if (p in G.inters) {
          return cost;
        }

        const x = p % GU;
        const y = p / GU;

        static foreach(i, a; AROUND) {{
          const ap = p + GAROUND[i];
          const ax = x + a[0];
          const ay = y + a[1];
          if (ax >= 0 && ay >= 0 && ax < N && ay < N && G.g[ay][ax] > 0 && !(ap in visited)) {
            route ~= RAROUND[i];
            visited[ap] = true;
            const r = dfs(ap, p, cost);
            if (r > 0) return r;
            route = route[0..$-1];
          }
        }}

        return 0;
      }

      G.removeIntersection(cur);
      if (G.inters.empty && cur != gn(SX, SY)) {
        G.inters[gn(SX, SY)] = Intersection(false);
      }

      alias Try = Tuple!(int, "cost", string, "route");
      auto tries = new Try[](0);
      foreach(i, a; AROUND) {
        const ax = cur%GU + a[0];
        const ay = cur/GU + a[1];
        if (ax >= 0 && ay >= 0 && ax < N && ay < N && G.g[ay][ax] > 0) {
          visited = [cur: true];
          route = "";
          route ~= RAROUND[i];
          const r = dfs(cur + GAROUND[i], cur, 1);
          if (r > 0) tries ~= Try(r, route);
        }
      }

      const best = tries.sort!"a.cost < b.cost"[0];
      ans ~= best.route;
      foreach(r; best.route) cur += WALKS[r];
      if (cur == gn(SX, SY)) break;
    }

    G.inters.deb;
    return ans;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop;
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
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
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(true) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
