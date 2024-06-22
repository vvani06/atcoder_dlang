void main() { runSolver(); }

// ----------------------------------------------

enum int GU = 80;
enum AROUND = [[-1,0], [0,-1], [1,0], [0,1]];
enum GAROUND = [-1, -GU, 1, GU];
enum RAROUND = "LURD";
enum WALKS = ['L': -1, 'U':-GU, 'R': 1, 'D': GU];
int gn(int x, int y) { return GU*y + x; }
int x(int p) {return p%GU; }
int y(int p) {return p/GU; }

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
    this.score = 1000000;
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

  int scoreAt(int p) {
    if (!(p in inters)) return 0;

    return inters[p].score;
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
      G.removeIntersection(cur);

      alias Try = Tuple!(int, "p", int, "score", string, "route");
      Try[int] dp;
      for(auto queue = [Try(cur, 0, "")].heapify!"a.score > b.score"; !queue.empty;) {
        auto t = queue.front;
        queue.removeFront;
        auto p = t.p;
        foreach(dir, a; AROUND) {
          const x = p.x + a[0];
          const y = p.y + a[1];
          if (x >= 0 && y >= 0 && x < N && y < N && G.at(x, y) > 0) {
            const ap = p + GAROUND[dir];
            const route = t.route ~ RAROUND[dir];
            const score = t.score + G.at(x, y);
            if (!(ap in dp) || dp[ap].score > score) {
              dp[ap] = Try(ap, score, route);
              queue.insert(dp[ap]);
            }
          }
        }
      }
      
      Try bestTry = Try(-1, int.max, "");
      foreach(inter; G.inters.keys) {
        if (!(inter in dp)) continue;

        if (bestTry.score > dp[inter].score) {
          bestTry = dp[inter];
        }
      }

      ans ~= bestTry.route;
      foreach(r; bestTry.route) {
        cur += WALKS[r];
        G.removeIntersection(cur);
      }
      if (G.inters.empty && cur != gn(SX, SY)) {
        G.inters[gn(SX, SY)] = Intersection(false);
      }
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
