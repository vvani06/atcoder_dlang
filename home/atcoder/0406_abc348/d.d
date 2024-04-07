void main() { runSolver(); }

void problem() {
  auto H = scan!int;
  auto W = scan!int;
  auto G = scan!string(H);
  auto N = scan!int;
  auto E = scan!int(3 * N).chunks(3);

  auto solve() {
    auto items = new int[][](H, W);
    foreach(e; E) {
      items[e[0] - 1][e[1] - 1] = e[2];
    }

    struct Cursor {
      int r, c, e;
    }

    Cursor start, goal;
    foreach(r; 0..H) foreach(c; 0..W) {
      if (G[r][c] == 'S') {
        start.r = r;
        start.c = c;
        start.e = items[r][c];
      }
      if (G[r][c] == 'T') {
        goal.r = r;
        goal.c = c;
      }
    }

    auto maxes = new int[][](H, W);
    foreach(ref m; maxes) m[] = -1;
    maxes[start.r][start.c] = start.e;
    for(auto queue = [start].heapify!"a.e < b.e"; !queue.empty;) {
      auto cur = queue.front;
      queue.removeFront;
      if (cur.r == goal.r && cur.c == goal.c) return true;

      if (maxes[cur.r][cur.c] != cur.e || cur.e <= 0) continue;

      foreach(dr, dc; zip([0, 1, 0, -1], [1, 0, -1, 0])) {
        auto r = cur.r + dr;
        auto c = cur.c + dc;
        if (min(r, c) < 0 || r >= H || c >= W || G[r][c] == '#') continue;

        auto e = max(cur.e - 1, items[r][c]);
        if (maxes[r][c].chmax(e)) queue.insert(Cursor(r, c, e));
      }
    }

    return false;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std, core.bitop;
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
