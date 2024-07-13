void main() { runSolver(); }

void problem() {
  auto A = scan!long(9);

  auto solve() {
    const half = A.sum / 2;

    int[] toMatrix(int pattern) {
      int[] ret;
      foreach(_; 0..9) {
        ret ~= (pattern % 3);
        pattern /= 3;
      }
      return ret;
    }

    int bingo(int[] arr) {
      foreach(color; 1..3) {
        foreach(i; 0..3) {
          if (3.iota.all!(x => arr[i * 3 + x] == color)) return color;
          if (3.iota.all!(x => arr[x * 3 + i] == color)) return color;
        }
        if (arr[0] == arr[4] && arr[4] == arr[8] && arr[8] == color) return color;
        if (arr[2] == arr[4] && arr[4] == arr[6] && arr[6] == color) return color;
      }
      return 0;
    }
    int bingoPattern(int pattern) { return bingo(toMatrix(pattern)); }

    int winner(int[] arr) {
      if (bingo(arr) != 0) return bingo(arr);

      long tScore = 9.iota.map!(i => arr[i] == 1 ? A[i] : 0).sum;
      return tScore > half ? 1 : 2;
    }

    bool[int] states;
    foreach(bn; 0..3^^9) {
      int[] cb;
      auto bnt = bn;
      foreach(_; 0..9) {
        cb ~= (bnt % 3);
        bnt /= 3;
      }
      if (cb.count(1) != 5 || cb.count(2) != 4) continue;
      
      states[bn] = winner(cb) == 1;
    }

    int turn = 8;
    while(turn >= 0 && states.length > 1) {
      auto color = turn % 2 + 1;
      auto pre = states.dup;
      states.clear;
      foreach(k, v; pre) {
        int[] bits;
        foreach(bi; 0..9) {
          if ((k / 3^^bi) % 3 == color) bits ~= bi;
        }

        foreach(bi; bits) {
          auto toState = k - color*3^^bi;

          auto bg = bingoPattern(toState);
          if (bg != 0) {
            states[toState] = bg == 1;
            continue;
          }
          
          if (color == 1) {
            states.require(toState, false);
            states[toState] |= v;
          } else {
            states.require(toState, true);
            states[toState] &= v;
          }
        }
      }
      turn--;
    }

    return states.values[0] ? "Takahashi" : "Aoki";
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

int[][] basePacks(int base, int size) {
  auto ret = new int[][](base^^size, size);
  foreach(i; 0..base^^size) {
    int x = i;
    foreach(b; 0..size) {
      ret[i][b] = x % base;
      x /= base;
    }
  }
  return ret;
}
