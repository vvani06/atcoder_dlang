void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto XYD = scan!int(3 * N).chunks(3).array;

  enum BOUNDARY = 6001;
  struct Coord {
    int x, y;

    Coord rotate45() {
      auto rx = x + y;
      auto ry = x - y + BOUNDARY/2;
      return Coord(
        min(BOUNDARY - 1, max(0, rx)),
        min(BOUNDARY - 1, max(0, ry)),
      );
    }
  }

  auto solve() {
    // 制約の X, Y, D が小さめなので、全ての座標に対してデータを持っておいて二次元累積和を作ることができる。
    // 二次元累積和があると「とある四角形領域にいる人数」を 0(1) で答えられるようになる。
    // ただし、今回は「マンハッタン距離」に基づく領域が問われており、これは菱形なので二次元累積和で使えない。
    // そこで、座標の45度回転というテクニックを使って菱形を正方形として扱えるようにしている。

    // 座標を45度回転して、2次元配列にフェネックの数をカウントしていく
    auto matrix = new int[][](BOUNDARY, BOUNDARY);
    foreach(xyd; XYD) {
      auto c = Coord(xyd[0], xyd[1]);
      auto r = c.rotate45();
      matrix[r.y][r.x]++;
    }
    // ↑の2次元配列に対して「2次元累積和」を作成しておく
    // 参考: https://qiita.com/drken/items/56a6b68edef8fc605821#4-%E4%BA%8C%E6%AC%A1%E5%85%83%E7%B4%AF%E7%A9%8D%E5%92%8C
    auto accMatrix = new int[][](BOUNDARY + 1, BOUNDARY + 1);
    foreach(y; 0..BOUNDARY) foreach(x; 0..BOUNDARY) {
      accMatrix[y + 1][x + 1] = accMatrix[y][x + 1] + accMatrix[y + 1][x] - accMatrix[y][x];
      if (matrix[y][x]) accMatrix[y + 1][x + 1]++;
    }

    foreach(xyd; XYD) {
      auto x = xyd[0];
      auto y = xyd[1];
      auto d = xyd[2];
      
      // マンハッタン距離 d の範囲（＝菱形）を 45度回転 して正方形の領域にする
      auto lt = Coord(x - d, y).rotate45();
      auto lb = Coord(x, y - d).rotate45();
      auto rt = Coord(x, y + d).rotate45();
      auto rb = Coord(x + d, y).rotate45();

      // 2次元配列に対してのクエリ算出部分
      // 参考: https://qiita.com/drken/items/56a6b68edef8fc605821#4-%E4%BA%8C%E6%AC%A1%E5%85%83%E7%B4%AF%E7%A9%8D%E5%92%8C
      int ans;
      ans += accMatrix[lt.y][lt.x] + accMatrix[rb.y + 1][rb.x + 1];
      ans -= accMatrix[lb.y + 1][lb.x] + accMatrix[rt.y][rt.x + 1];
      writeln(ans);
    }
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
