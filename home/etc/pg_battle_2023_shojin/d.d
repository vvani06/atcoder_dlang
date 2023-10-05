void main() { runSolver(); }

void problem() {
  auto P = scan!string(12).map!(s => s.map!(c => c == '#').array).array.chunks(4).array;

  struct Polyomino {
    bool[4][4] p;
    int minX = 4, minY = 4, maxX, maxY;

    this(bool[][] v) {
      foreach(x, y; cartesianProduct(4.iota, 4.iota)) p[y][x] = v[y][x];
    }

    bool valid() {
      int c;
      foreach(x, y; cartesianProduct(4.iota, 4.iota)) c += p[y][x];
      return c >= 1;
    }

    Polyomino rotate() {
      auto rotated = new bool[][](4, 4);
      foreach(x, y; cartesianProduct(4.iota, 4.iota)) rotated[y][x] = p[x][3 - y];
      return Polyomino(rotated);
    }
    
    Polyomino shift(int x, int y) {
      auto shifted = new bool[][](4, 4);
      foreach(dx, dy; cartesianProduct(4.iota, 4.iota)) {
        if (p[dy][dx]) {
          auto nx = x + dx; 
          auto ny = y + dy;
          if (min(nx, ny) < 0 || max(nx, ny) >= 4) return Polyomino();
          shifted[ny][nx] = p[dy][dx];
        }
      }
      return Polyomino(shifted);
    }

    int fill(ref bool[4][4] grid) {
      int filled;
      static foreach(x, y; cartesianProduct(4.iota, 4.iota)) {{
        if (p[y][x]) {
          if (grid[y][x]) return -1;

          grid[y][x] = true;
          filled++;
        }
      }}
      return filled;
    }
  }

  auto solve() {
    auto polyominos = P.map!(p => [Polyomino(p)]).array;
    foreach(i; 0..3) {
      foreach(r; 1..4) polyominos[i] ~= polyominos[i][$ - 1].rotate();
      foreach(r; 0..4) foreach(dx; -3..4) foreach(dy; -3..4) {
        if (dx == 0 && dy == 0) continue;
        auto shifted = polyominos[i][r].shift(dx, dy);
        if (shifted.valid) polyominos[i] ~= shifted;
      }
    }
    
    foreach(choices; cartesianProduct(polyominos[0], polyominos[1], polyominos[2])) {
      bool[4][4] grid;
      
      auto filled = choices.array.map!(p => p.fill(grid)).array;
      if (filled.all!"a >= 1" && filled.sum == 16) return true;
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
