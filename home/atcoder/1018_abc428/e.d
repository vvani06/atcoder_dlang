void main() { runSolver(); }

void problem() {
  auto H = scan!int();
  auto W = scan!int();
  auto G = scan!string(H).map!"a.array".array;
  auto seed = unpredictableSeed;

  alias Grid = bool[][];

  auto solve() {
    int tr, tc;
    foreach(r; 0..H) foreach(c; 0..W) {
      if (G[r][c] == 'T') {
        tr = r;
        tc = c;
        G[r][c] = '.';
      }
    }

    long matrixHash(Grid g) {
      long ret;
      foreach(r; 0..H) foreach(c; 0..W) {
        if (g[r][c]) ret ^= (r * 1000 + c).hashOf(seed);
      }
      return ret;
    }

    Grid shift(Grid grid, int dir) {
      enum DR = [-1, 0, 1, 0];
      enum DC = [0, -1, 0, 1];

      auto ret = new bool[][](H, W);
      foreach(r; 0..H) foreach(c; 0..W) {
        auto nr = r + DR[dir];
        auto nc = c + DC[dir];

        if (min(nr, nc) < 0 || nr >= H || nc >= W) {
          continue;
        }

        ret[r][c] = grid[nr][nc];
      }
      return ret;
    }

    auto boolGrid = G.map!(row => row.map!(c => c == '#').array).array;

    auto queue = [matrixHash(boolGrid)].redBlackTree;
    auto pre = queue.dup;

    int[long] score = [matrixHash(boolGrid): 0];
    Grid[long] memo = [matrixHash(boolGrid): boolGrid.map!array.array];

    foreach(step; 0..100_000) {
      swap(queue, pre);
      queue.clear;
      foreach(hash; pre) {
        // hash.deb;
        auto grid = memo[hash];
        if (!grid.joiner.canFind(true)) return step;

        foreach(dir; 0..4) {
          auto next = shift(grid, dir);
          // next.deb;
          if (next[tr][tc]) continue;

          auto nextHash = matrixHash(next);
          if (nextHash in memo) continue;

          memo[nextHash] = next.map!array.array;
          queue.insert(nextHash);
        }
      }

      if (queue.empty) break;
    }

    return -1;
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
void deb(T ...)(T t){ debug t.writeln; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
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

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}
