void main() { runSolver(); }

struct Bomb {
  long x, y, start, end;
  GridPoint gp() { return GridPoint(x, y); }
}

void problem() {
  auto H = scan!int;
  auto W = scan!int;
  auto N = scan!int;
  auto START = GridPoint(0, 0);
  auto RECT = GridPoint(W, H);
  auto B = Bomb(START.x, START.y, 0, 0) ~ scan!int(4 * N).chunks(4).map!(b => Bomb(b[1]-1, b[0]-1, b[2], b[3])).array;
  auto G = cast(char[][])scan!string(H);
  N++;

  auto solve() {
    auto dist = new long[][](N, N);
    foreach(ref d; dist) d[] = int.max;
    foreach(from; 0..N) {
      auto visited = new bool[][](H, W);
      long step;
      for(auto q = new DList!GridPoint(B[from].gp); !q.empty;) {
        foreach(p; q.array) {
          q.removeFront;
          if (p.of(visited)) continue;

          visited[p.y][p.x] = true;
          foreach(to; 0..N) {
            if (B[to].gp == p) dist[from][to].chmin(step);
          }
          
          foreach(a; p.around(RECT)) {
            if (a.of(G) == '#' || a.of(visited)) continue;

            q.insertBack(a);
          }
        }
        step++;
      }
    }
    // dist.deb;

    auto dp = new long[][](2^^N, N);
    foreach(ref d; dp) d[] = int.max;
    dp[1][0] = 0;

    auto statePerBits = new int[][](N + 1, 0);
    foreach(b; 0..2^^N) statePerBits[b.popcnt] ~= b;

    auto bitNums = (N + 1).iota.map!(i => 2^^i).array;
    int ans;
    foreach(bitCount; 1..N) {
      foreach(b; statePerBits[bitCount]) {
        foreach(from; 0..N) {
          if (dp[b][from] == int.max) continue;

          foreach(to; 1..N) {
            auto tn = bitNums[to];
            if ((b & tn) == tn) continue;
            if (dist[from][to] == int.max) continue;

            auto shortest = dp[b][from] + dist[from][to];
            if (B[to].start > shortest) {
              shortest += ((B[to].start - shortest + 1) / 2) * 2;
            }

            if (B[to].end >= shortest) {
              dp[b | tn][to].chmin(shortest);
              ans = max(ans, bitCount);
            }
          }
        }
      }
    }

    // dp.deb;

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
struct ModInt(uint MD) if (MD < int.max) {ulong v;this(string v) {this(v.to!long);}this(int v) {this(long(v));}this(long v) {this.v = (v%MD+MD)%MD;}void opAssign(long t) {v = (t%MD+MD)%MD;}static auto normS(ulong x) {return (x<MD)?x:x-MD;}static auto make(ulong x) {ModInt m; m.v = x; return m;}auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r.v));}auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r.v));}auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r.v%MD).to!ulong);}auto opBinary(string op:"^^", T)(T r) const {long x=v;long y=1;while(r){if(r%2==1)y=(y*x)%MD;x=x^^2%MD;r/=2;} return make(y);}auto opBinary(string op:"/")(ModInt r) const {return this*memoize!inv(r);}static ModInt inv(ModInt x) {return x^^(MD-2);}string toString() const {return v.to!string;}auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}}
alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);
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
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct GridPoint {
  static enum ZERO = GridPoint(0, 0);
  long x, y;
 
  static GridPoint reversed(long y, long x) {
    return GridPoint(x, y);
  }
 
  this(long x, long y) {
    this.x = x;
    this.y = y;
  }
 
  inout GridPoint left() { return GridPoint(x - 1, y); }
  inout GridPoint right() { return GridPoint(x + 1, y); }
  inout GridPoint up() { return GridPoint(x, y - 1); }
  inout GridPoint down() { return GridPoint(x, y + 1); }
  inout GridPoint leftUp() { return GridPoint(x - 1, y - 1); }
  inout GridPoint leftDown() { return GridPoint(x - 1, y + 1); }
  inout GridPoint rightUp() { return GridPoint(x + 1, y - 1); }
  inout GridPoint rightDown() { return GridPoint(x + 1, y + 1); }
  inout GridPoint[] around() { return [left(), up(), right(), down()]; }
  inout GridPoint[] around(GridPoint max) { GridPoint[] ret; if (x > 0) ret ~= left; if(x < max.x-1) ret ~= right; if(y > 0) ret ~= up; if(y < max.y-1) ret ~= down; return ret; }
  inout T of(T)(inout ref T[][] grid) { return grid[y][x]; }
}
 