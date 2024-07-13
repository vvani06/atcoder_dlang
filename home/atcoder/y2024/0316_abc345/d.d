void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto H = scan!int;
  auto W = scan!int;
  auto AB = scan!int(2 * N).chunks(2).array.sort!"a[0]*a[1] > b[0]*b[1]";

  auto solve() {
    struct Coord {
      int x, y;
    }

    struct Rect {
      int w, h;

      Rect rotate() {
        return Rect(h, w);
      }

      int segment() { return w * h; }
      Coord[] coords() {
        Coord[] ret;
        foreach(y; 0..H - h + 1) foreach(x; 0..W - w + 1) {
          ret ~= Coord(x, y);
        }
        return ret;
      }
    }

    auto rects = AB.map!(ab => Rect(ab[0], ab[1])).array;

    bool[string] memo;
    bool subSolve(Rect[] pat) {
      auto mk = pat.to!string;
      if (mk in memo) return memo[mk];

      bool[10][10] state;
      bool[Coord] rest;
      foreach(y; 0..H) foreach(x; 0..W) rest[Coord(x, y)] = true;

      bool fill(Rect r, Coord coord, bool to) {
        if (coord.x + r.w > W) return false;
        if (coord.y + r.h > H) return false;

        if (to) {
          foreach(x; coord.x..coord.x + r.w) foreach(y; coord.y..coord.y + r.h) {
            if (state[y][x]) return false;
          }
        }

        foreach(x; coord.x..coord.x + r.w) foreach(y; coord.y..coord.y + r.h) {
          state[y][x] = to;
          if (to) rest.remove(Coord(x, y)); else rest[Coord(x, y)] = true;
        }
        return true;
      }

      bool ans;
      bool dfs(int r) {
        if (r == pat.length) {
          if (rest.empty) ans = true;
          return ans;
        }
        
        foreach(rect; [pat[r], pat[r].rotate].uniq) {
          foreach(coord; rest.keys) {
            if (!fill(rect, coord, true)) continue;

            if (dfs(r + 1)) return true;
            fill(rect, coord, false);
          }
        }
        return false;
      }

      dfs(0);
      return memo[mk] = ans;
    }

    foreach(i; 1..2^^N) {
      int seg;
      Rect[] p;
      for(int n = 0; n < N; n++) {
        if ((i & 2^^n) != 0) {
          seg += rects[n].segment;
          p ~= rects[n];
        }
      }

      if (seg == H * W) {
        if (subSolve(p)) return true;
      }
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
