void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto AB = scan!int(2 * N).chunks(2).array;

  struct State {
    int used;
    int[] waysCache;
    bool cached;

    int turn() {
      return (used.popcnt() / 2) % 2;
    }

    int[] ways() {
      if (cached) return waysCache;

      int[] ret;
      foreach(i; 0..N - 1) {
        if ((used & 2^^i) != 0) continue;
        foreach(j; i + 1..N) {
          if ((used & 2^^j) != 0) continue;
          if (AB[i][0] == AB[j][0] || AB[i][1] == AB[j][1]) waysCache ~= used | 2^^i | 2^^j;
        }
      }
      cached = true;
      return waysCache;
    }

    bool noWay() {
      return ways.empty;
    }
  }

  auto solve() {
    State[int] states;
    states[0] = State(0);
    
    for(auto queue = DList!int(0); !queue.empty;) {
      auto cur = queue.front;
      queue.removeFront;

      auto from = &states[cur];
      foreach(w; from.ways) {
        if (w in states) continue;

        states[w] = State(w);
        queue.insertBack(w);
      }
    }
    
    bool[int] memo;
    bool dfs(int s) {
      if (s in memo) return memo[s];

      auto state = &states[s];
      if (state.noWay()) return state.turn() != 0;

      bool ret;
      if (state.turn != 0) {
        ret = true;
        foreach(w; state.ways) {
          ret &= dfs(w);
        }
      } else {
        ret = false;
        foreach(w; state.ways) {
          ret |= dfs(w);
        }
      }

      return memo[s] = ret;
    }

    bool ans = dfs(0);

    return ans ? "Takahashi" : "Aoki";
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
import core.bitop;
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
