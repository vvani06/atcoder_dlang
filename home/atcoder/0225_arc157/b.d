void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto K = scan!int;
  auto S = scan!string;

  real value(int v, int t, int r) {
    if (v > r) {
      t = min(1, t);
    }

    return (v - 1 + t).to!real / v.to!real;
  }

  auto solve() {
    auto countX = S.count('X').to!int;
    auto groups = S.group;
    int[][] continuasY;
    int[][] continuasX;

    dchar pre;
    foreach(g; groups) {
      if (g[0] == 'Y') {
        continuasY ~= [g[1], pre == 'X' ? 1 : 0];
        if (!continuasX.empty) continuasX[$ - 1][1]++;
      } else {
        continuasX ~= [g[1], pre == 'Y' ? 1 : 0];
        if (!continuasY.empty) continuasY[$ - 1][1]++;
      }
      pre = g[0];
    }

    auto heapY = continuasY.heapify!"a[0] == b[0] ? a[1] > b[1] : a[0] < b[0]";
    auto heapX = 3.iota.map!(i => continuasX.filter!(a => a[1] == i).array.heapify!"a[0] > b[0]").array;

    if (K >= countX) {
      K -= countX;
      int ans = N - 1;
      foreach(_; 0..K) {
        auto y = heapY.front; heapY.removeFront;
        if (y[0] > 1) {
          ans--;
        } else {
          ans -= y[1];
        }
        y[0]--;
        if (y[0] > 0) heapY.insert(y);
      }

      return ans;
    }

    // heapX.dup.deb;
    int ans = heapY.map!"a[0] - 1".sum;
    int rest = K;
    while(rest > 0) {
      real best = -1;
      int besti;
      foreach(i, heap; heapX) {
        if (!heap.empty) {
          auto t = heap.front;
          if (best.chmax(value(t[0], t[1], rest))) {
            besti = i.to!int;
          }
        }
      }

      auto x = heapX[besti].front;
      heapX[besti].removeFront;
      if (x[0] > 1) {
        ans += min(1, x[1]);
        if (x[1] == 0) x[1] = 1;
        x[0]--;

        if (x[1] == 1) heapX[1].insert(x);
        if (x[1] == 2) heapX[2].insert(x);
      } else {
        ans += x[1];
      }
      rest--;
    }
    return ans;
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
  debug { BORDER.writeln; while(!stdin.eof) { problem(); } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
