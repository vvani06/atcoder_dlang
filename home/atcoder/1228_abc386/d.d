void main() { runSolver(); }

alias Fill = Tuple!(int, "r", int, "c", bool, "color");

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto F = M.iota.map!(_ => Fill(scan!int, scan!int, scan == "B")).array;

  auto solve() {
    int[][int] blackRow, whiteRow;
    foreach(f; F.sort!"a.c < b.c") {
      blackRow.require(f.r, new int[](0));
      whiteRow.require(f.r, new int[](0));
      if (f.color) {
        blackRow[f.r] ~= f.c;
      } else {
        whiteRow[f.r] ~= f.c;
      }

      if (!(blackRow[f.r].empty || whiteRow[f.r].empty)) {
        if (blackRow[f.r][$ - 1] > whiteRow[f.r][0]) return false;
      }
    }
    int[][int] blackCol, whiteCol;
    foreach(f; F.sort!"a.r < b.r") {
      blackCol.require(f.c, new int[](0));
      whiteCol.require(f.c, new int[](0));
      if (f.color) {
        blackCol[f.c] ~= f.r;
      } else {
        whiteCol[f.c] ~= f.r;
      }
      
      if (!(blackCol[f.c].empty || whiteCol[f.c].empty)) {
        if (blackCol[f.c][$ - 1] > whiteCol[f.c][0]) return false;
      }
    }

    int borderC = 0;
    int borderR = N;
    foreach(c; whiteCol.keys.sort) {
      auto wc = whiteCol[c];
      if (!wc.empty) borderR = min(borderR, wc[$ - 1] - 1);
      auto bc = blackCol[c];
      if (!bc.empty) {
        if (bc[$ - 1] > borderR) return false;
      }

      [c, borderR, borderC].deb;
    }

    return true;
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

struct Eratosthenes {
  bool[] isPrime;
  int[] rawPrimes;
  int[] spf;

  this(int lim) {
    isPrime = new bool[](lim + 1);
    isPrime[2..$] = true;
    spf = new int[](lim + 1);
    spf[] = int.max;
    spf[0..2] = 1;

    foreach (i; 2..lim+1) {
      if (isPrime[i]) {
        spf[i] = i;

        auto x = i*2;
        while (x <= lim) {
          isPrime[x] = false;
          spf[x].chmin(i);
          x += i;
        }
      }
    }

    foreach(p; 2..lim + 1) {
      if (isPrime[p]) rawPrimes ~= p;
    }
  }

  auto primes() { return rawPrimes.assumeSorted; }

  int[int] factorize(int x) {
    int[int] ret;
    while(x > 1) {
      ret[spf[x]]++;
      x /= spf[x];
    }
    return ret;
  }
}