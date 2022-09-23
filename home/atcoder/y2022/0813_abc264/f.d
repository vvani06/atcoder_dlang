void main() { runSolver(); }

void problem() {
  auto H = scan!int;
  auto W = scan!int;
  auto R = scan!long(H);
  auto C = scan!long(W);
  auto A = scan!string(H).map!(s => s.map!(c => c == '1').array).array;

  auto solve() {
    // 座標ごとに [反転無し, 列反転済み, 行反転済み, 行列反転済み] 時の最小コスト
    auto dp = new long[][][](H, W, 4);
    foreach(ref d; dp) foreach(ref dd; d) dd[] = long.max / 4;
    dp[0][0] = [0, C[0], R[0], R[0] + C[0]];
    foreach(t; 1..H + W) {
      foreach(x; 0..t + 1) {
        auto y = t - x;
        if (y >= H || x >= W) continue;

        if (x > 0) {
          // 左からの遷移
          auto to = dp[y][x];
          auto from = dp[y][x - 1];
          if (A[y][x] == A[y][x - 1]) {
            // 同色
            to[0].chmin(from[0]);        // 同色なので、反転無しからの遷移はノーコスト
            to[1].chmin(from[1] + C[x]); // 列反転済みからの遷移なので、異色になる
            to[2].chmin(from[2]);        // 行反転済みからの遷移。この行も反転済みなので同色
            to[3].chmin(from[3] + C[x]); // 行列ともに反転済みからの遷移。この行も反転済みだけど遷移元は列も反転済みなので異色
          } else {
            to[0].chmin(from[1]);
            to[1].chmin(from[0] + C[x]);
            to[2].chmin(from[3]);
            to[3].chmin(from[2] + C[x]);
          }
        }
        if (y > 0) {
          auto to = dp[y][x];
          auto from = dp[y - 1][x];
          if (A[y][x] == A[y - 1][x]) {
            to[0].chmin(from[0]);
            to[1].chmin(from[1]);
            to[2].chmin(from[2] + R[y]);
            to[3].chmin(from[3] + R[y]);
          } else {
            to[0].chmin(from[2]);
            to[1].chmin(from[3]);
            to[2].chmin(from[0] + R[y]);
            to[3].chmin(from[1] + R[y]);
          }
        }
      }
    }

    // dp.each!(a => a.deb);
    return dp[H - 1][W - 1].minElement;
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
