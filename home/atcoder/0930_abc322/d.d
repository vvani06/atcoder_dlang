void main() { runSolver(); }

void problem() {
  auto P = scan!string(12).map!(s => s.map!(c => c == '#').array).array.chunks(4).array;

  auto solve() {
    auto rotate(bool[][] grid) {
      auto ret = grid.map!"a.dup".array;
      foreach(y; 0..4) foreach(x; 0..4) ret[y][x] = grid[x][3 - y];
      return ret;
    }

    auto rotated = new bool[][][][](3, 4, 4, 4);
    foreach(i; 0..3) {
      rotated[i][0] = rotate(P[i]);
      foreach(r; 1..4) rotated[i][r] = rotate(rotated[i][r - 1]);
    }

    foreach(rots, xs, ys; cartesianProduct(basePacks(4, 3), basePacks(7, 3), basePacks(7, 3))) {
      bool judge() {
        bool[4][4] grid;
        int filled;
        static foreach(i; 0..3) {{
          auto p = rotated[i][rots[i]];
          auto offsetX = xs[i];
          auto offsetY = ys[i];

          static foreach(dx, dy; cartesianProduct(4.iota, 4.iota)) {
            if (p[dy][dx]) {
              auto y = offsetY - 3 + dy;
              auto x = offsetX - 3 + dx;
              if (min(x, y) < 0 || max(x, y) >= 4 || grid[y][x]) return false;

              grid[y][x] = true;
              filled++;
            }
          }
        }}
        return filled == 16;
      }
      
      if (judge()) return true;
    }

    return false;
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

long[][] basePacks(long base, long size) {
  auto ret = new long[][](base^^size, size);
  foreach(i; 0..base^^size) {
    long x = i;
    foreach(b; 0..size) {
      ret[i][b] = x % base;
      x /= base;
    }
  }
  return ret;
}