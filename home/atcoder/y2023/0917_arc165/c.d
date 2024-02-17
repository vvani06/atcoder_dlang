void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto E = scan!int(3 * M).chunks(3).array;

  auto solve() {
    enum INF = int.max / 2;
    auto colors = new int[](N + 1);
    auto mins = new int[][](N + 1, 3);
    foreach(ref m; mins) m[] = INF;

    long ans = long.max;
    foreach(e; E.multiSort!("a[2] < b[2]", "a[0] < b[0]", "a[1] < b[1]")) {
      auto u = e[0];
      auto v = e[1];
      auto w = e[2];
      
      if (colors[u] == 0 && colors[v] == 0) {
        colors[u] = 1;
        colors[v] = 2;
        mins[u][2].chmin(w);
        mins[v][1].chmin(w);
      } else if (colors[u] * colors[v] == 0) {
        if (colors[u] == 0) {
          const c = 3 - colors[v];
          colors[u] = c;
          if (mins[v][c] != INF) {
            ans = min(ans, mins[v][c] + w);
          }
          mins[v][c].chmin(w);
          mins[u][colors[v]].chmin(w);
        } else {
          const c = 3 - colors[u];
          colors[v] = c;
          if (mins[u][c] != INF) {
            ans = min(ans, mins[u][c] + w);
          }
          mins[u][c].chmin(w);
          mins[v][colors[u]].chmin(w);
        }
      } else {
        if (colors[u] == colors[v]) {
          ans = min(ans, w);
        } else {
          ans = min(ans, w + mins[u][3 - colors[u]]);
          ans = min(ans, w + mins[v][3 - colors[v]]);
        }
        break;
      }
    }

    return ans;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
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
