void main() { runSolver(); }

void problem() {
  auto H = scan!int;
  auto W = scan!int;
  auto A = scan!int(H * W).chunks(W).array;
  
  auto solve() {
    auto inverted = new int[](H);

    bool isolations(int x, int y, bool ignoreDown = false) {
      auto xs = [x    , x    , x - 1, x + 1];
      auto ys = [y - 1, y + 1, y    , y    ];

      bool isolated = true;
      auto base = A[y][x] ^ inverted[y];
      foreach(xy; zip(xs, ys)) {
        auto tx = xy[0];
        auto ty = xy[1];
        if (min(tx, ty) < 0 || tx >= W || ty >= H) continue;
        if (ignoreDown && ty > y) continue;

        auto comparee = A[ty][tx] ^ inverted[ty];
        if (base == comparee) isolated = false;
      }
      return isolated;
    }

    int countRow(int y, bool ignoreDown = false) {
      int count;
      foreach(x; 0..W) if (isolations(x, y, ignoreDown)) count++;
      return count;
    }

    auto dp = new int[][](H, 4);
    foreach(ref d; dp) d[] = int.max / 2;
    dp[0][2..4] = [0, 1];
    foreach(y; 1..H) {
      foreach(pat; zip([0, 0, 1, 1, 2, 2, 3, 3], [0, 1, 0, 1, 0, 1, 0, 1])) {
        inverted[y - 1] = pat[0] % 2;
        inverted[y] = pat[1];

        auto pre = pat[0] >= 2 ? countRow(y - 1) : 0;
        auto cur = countRow(y, true);
        if (y < H) {
          if (pre == 0) {
            auto ofs = cur == 0 ? 0 : 2;
            dp[y][pat[1] + ofs].chmin(dp[y - 1][pat[0]] + pat[1]);
          }
        } else {
          if (pre == 0 && countRow(y) == 0) {
            dp[y][pat[1]].chmin(dp[y - 1][pat[0]] + pat[1]);
          }
        }
      }
    }

    dp.deb;
    auto ans = dp[$ - 1].minElement;
    return ans > H ? -1 : ans;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
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
