void main() { runSolver(); }

void problem() {
  auto H = scan!int;
  auto W = scan!int;
  auto T = scan!int;
  auto A = scan!string(H);

  auto solve() {
    alias Coord = Tuple!(int, "x", int, "y");
    auto coords = new Coord[](2);
    foreach(y; 0..H) foreach(x; 0..W) {
      if (A[y][x] == 'S') coords[0] = Coord(x, y);
      if (A[y][x] == 'G') coords[1] = Coord(x, y);
      if (A[y][x] == 'o') coords ~= Coord(x, y);
    }
    auto targets = coords.length.to!int;
    auto INF = T + 1;

    // スタート地点・ゴール地点・お菓子ポイント 間の移動コストを算出
    int[] distancesFrom(int from) {
      auto steps = new int[][](H, W);
      foreach(ref s; steps) s[] = INF;
      steps[coords[from].y][coords[from].x] = 0;

      for(auto queue = DList!Coord(coords[from]); !queue.empty;) {
        auto cur = queue.front; queue.removeFront;

        enum DIRS = zip([-1, 0, 1, 0], [0, -1, 0, 1]);
        foreach(dx, dy; DIRS) {
          auto x = cur.x + dx;
          auto y = cur.y + dy;
          if (min(x, y) < 0 || x >= W || y >= H) continue;
          if (A[y][x] == '#') continue;

          if (steps[y][x] == INF) {
            steps[y][x] = steps[cur.y][cur.x] + 1;
            queue.insertBack(Coord(x, y));
          }
        }
      }
      return coords.map!(c => steps[c.y][c.x]).array;
    }
    auto distances = targets.iota.map!(i => distancesFrom(i)).array;
    // distances.deb;

    // 巡回セールスマンで訪問状態ごとの最小コストを求める
    auto costs = new int[][](2^^targets, targets);
    foreach(ref s; costs) s[] = INF;
    costs[1][0] = 0;

    auto bits = 20.iota.map!"2 ^^ a".array;
    foreach(fromState; 1..2^^targets) {
      foreach(to; 1..targets) {
        if (fromState & bits[to]) continue;

        auto toState = fromState + bits[to];
        foreach(from; 0..targets) {
          if (!(fromState & bits[from])) continue;

          costs[toState][to].chmin(costs[fromState][from] + distances[from][to]);
        }
      }
    }

    // 訪問状態のうち「スタート地点・ゴール地点を訪問済み」かつ「最後にゴール地点にいる」ものを選んで
    // その最小コストが T 以下ならお菓子ポイントを訪れてる分を ans にする
    int ans = -1;
    foreach(state; 0..2^^targets) {
      if ((state & 3) != 3) continue;

      int score = state.popcnt - 2;
      if (costs[state][1] <= T) ans = max(ans, score);
    }
    return ans;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
import core.bitop;
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
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
  static import std.datetime.stopwatch;
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
