void main() { runSolver(); }

void problem() {
  auto H = scan!int;
  auto W = scan!int;
  auto G = scan!string(H).map!"a.array".array;

  auto solve() {
    alias Coord = Tuple!(int, "x", int, "y");
    alias Line = Tuple!(int, "x", int, "y", int, "dx", int, "dy");
    auto queue = DList!Line();

    Coord start, goal;
    foreach(y; 0..H) foreach(x; 0..W) {
      if (G[y][x] == '<') queue.insertBack(Line(x, y, -1, 0));
      if (G[y][x] == '>') queue.insertBack(Line(x, y, 1, 0));
      if (G[y][x] == '^') queue.insertBack(Line(x, y, 0, -1));
      if (G[y][x] == 'v') queue.insertBack(Line(x, y, 0, 1));

      if (G[y][x] == 'S') start = Coord(x, y);
      if (G[y][x] == 'G') goal = Coord(x, y);
    }
    G[goal.y][goal.x] = '.';

    enum BLOCK = "#><^v";
    while(!queue.empty) {
      auto p = queue.front; queue.removeFront;
      
      auto x = p.x + p.dx;
      auto y = p.y + p.dy;
      while(min(x, y) >= 0 && x <= W - 1 && y <= H - 1) {
        if (BLOCK.canFind(G[y][x])) break;

        G[y][x] = '!';
        x += p.dx;
        y += p.dy;
      }
    }

    // G.map!"a.to!string".joiner("\n").deb;

    auto steps = new int[][](H, W);
    enum INF = int.max / 2;
    foreach(ref s; steps) s[] = INF;
    steps[start.y][start.x] = 0;

    for(auto coords = DList!Coord(start); !coords.empty;) {
      auto c = coords.front; coords.removeFront;
      foreach(dx, dy; zip([-1, 0, 1, 0], [0, -1, 0, 1])) {
        auto x = c.x + dx;
        auto y = c.y + dy;
        if (min(x, y) < 0 || x >= W || y >= H || G[y][x] != '.' || steps[y][x] != INF) continue;

        steps[y][x] = steps[c.y][c.x] + 1;
        coords.insertBack(Coord(x, y));
      }
    }

    auto ans = steps[goal.y][goal.x];
    return ans == INF ? -1 : ans;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
T[] compress(T)(T[] arr, T origin = T.init) { T[T] indecies; arr.dup.sort.uniq.enumerate(origin).each!((i, t) => indecies[t] = i); return arr.map!(t => indecies[t]).array; }
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
struct ModInt(uint MD) if (MD < int.max) {ulong v;this(string v) {this(v.to!long);}this(int v) {this(long(v));}this(long v) {this.v = (v%MD+MD)%MD;}void opAssign(long t) {v = (t%MD+MD)%MD;}static auto normS(ulong x) {return (x<MD)?x:x-MD;}static auto make(ulong x) {ModInt m; m.v = x; return m;}auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r.v));}auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r.v));}auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r.v%MD).to!ulong);}auto opBinary(string op:"^^", T)(T r) const {long x=v;long y=1;while(r){if(r%2==1)y=(y*x)%MD;x=x^^2%MD;r/=2;} return make(y);}auto opBinary(string op:"/")(ModInt r) const {return this*memoize!inv(r);}static ModInt inv(ModInt x) {return x^^(MD-2);}string toString() const {return v.to!string;}auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}}
alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);
string asAnswer(T ...)(T t) {
  string ret;
  foreach(i, a; t) {
    if (i > 0) ret ~= "\n";
    alias A = typeof(a);
    static if (isIterable!A && !is(A == string)) {
      string[] rets;
      foreach(b; a) rets ~= asAnswer(b);
      static if (isInputRange!A) ret ~= rets.joiner(" ").to!string; else ret ~= rets.joiner("\n").to!string; 
    } else {
      static if (is(A == float) || is(A == double) || is(A == real)) ret ~= "%.16f".format(a);
      else static if (is(A == bool)) ret ~= YESNO[a]; else ret ~= "%s".format(a);
    }
  }
  return ret;
}
void deb(T ...)(T t){ debug asAnswer(t).writeln; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == void)) fn();
  else if (is(T == string)) fn().writeln;
  else asAnswer(fn()).writeln;
}
void runSolver() {
  static import std.datetime.stopwatch;
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

int[] topologicalSort(int[][] g) {
  auto size = g.length.to!int;
  auto depth = new int[](size);
  foreach(e; g) foreach(p; e) depth[p]++;

  auto q = heapify!"a > b"(new int[](0));
  foreach(i; 0..size) if (depth[i] == 0) q.insert(i);

  int[] sorted;
  while(!q.empty) {
    auto p = q.front;
    q.removeFront;
    foreach(n; g[p]) {
      depth[n]--;
      if (depth[n] == 0) q.insert(n);
    }

    sorted ~= p;
  }

  return sorted;
}