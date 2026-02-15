void main() { runSolver(); }

void problem() {
  enum LIMIT = 10 ^^ 7;
  auto T = scan!int;
  auto sieze = LinearSieze(LIMIT);

  auto subSolve(int N, int[] A) {
    BinaryHeap!(int[])[int] heaps;

    foreach(a; A) {
      foreach(prime, count; sieze.factors(a).asTuples!2) {
        heaps.require(prime, [0].heapify);
        heaps[prime].insert(count);
      }
    } 

    MInt9 mulSum = MInt9(1);
    foreach(prime, heap; heaps) {
      mulSum *= MInt9(prime) ^^ heap.front;
    }

    MInt9[] ans;
    foreach(a; A) {
      auto ms = mulSum;
      foreach(prime, count; sieze.factors(a).asTuples!2) {
        if (count != heaps[prime].front) continue;

        heaps[prime].removeFront();
        if (count != heaps[prime].front) ms /= MInt9(prime ^^ (count - heaps[prime].front));
        heaps[prime].insert(count);
      }
      ans ~= ms;
    }

    return asAnswer(ans);
  }

  auto solve() {
    foreach(_; 0..T) {
      auto N = scan!int;
      writeln(subSolve(N, scan!int(N)));
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

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}

struct LinearSieze {
  int limit;
  int[] primes;
  int[] spf;

  this(int limit) {
    this.limit = limit;
    spf = new int[](limit + 1);

    foreach(d; iota(2, limit + 1)) {
      if (spf[d] == 0) {
        spf[d] = d;
        primes ~= d;
      }

      foreach(p; primes) {
        if (p * d > limit || p > spf[d]) break; else spf[p * d] = p;
      }
    }
  }

  alias Factors = Tuple!(int, int)[];
  Factors factors(int n) {
    Factors ret;
    for(auto prime = spf[n]; prime > 1;) {
      int count;
      while(n % prime == 0) {
        count++;
        n /= prime;
      }

      ret ~= tuple(prime, count);
      prime = spf[n];
    }
    return ret;
  }
}