void main() { runSolver(false); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto K = scan!int;
  auto T = scan!string.map!"a == 'o'".array;
  auto S = scan!string(N).map!(s => s.map!"a == 'o'".array).array;
  auto Q = scan!int(scan!int * 2).map!"a - 1".chunks(2).array;

  auto solve() {
    bool judge(int player) {
      int rest = M;
      foreach(k; 0..K) {
        auto collects = iota(N).count!(i => T[k] == S[i][k]);
      }

      return false;
    }

    foreach(i, j; Q.asTuples!2) {
      S[i][j] ^= 1;
      writeln(asAnswer(judge(i)));
    }
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
void deb(T ...)(T t){ debug t.writeln; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
  else asAnswer(fn()).writeln;
}
void runSolver(bool multiCase = false) {
  static import std.datetime.stopwatch;
  debug { if (multiCase) writeln("! Run as multi-case"); }
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(multiCase ? scan!int : 1)); BORDER.writeln; } }
  else foreach(_; 0..multiCase ? scan!int : 1) problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct ModInt(uint MD) if (MD < int.max) {
  ulong v;
  this(string v) {this(v.to!long);}
  this(int v) {this(long(v));}
  this(long v) {this.v = (v%MD+MD)%MD;}
  void opAssign(long t) {v = (t%MD+MD)%MD;}
  static auto normS(ulong x) {return (x<MD)?x:x-MD;}
  static auto make(ulong x) {ModInt m; m.v = x; return m;}
  auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r.v));}
  auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r.v));}
  auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r.v%MD).to!ulong);}
  static long pow(long x, long n) { long ans = 1; while (n > 0) { if ((n & 1) == 1) {ans = ans * x % MD;} x = x * x % MD; n >>= 1;} return ans;}
  auto opBinary(string op:"^^", T)(T r) const {return make(pow(v, r));}
  auto opBinary(string op:"/")(ModInt r) const {return this*memoize!inv(r);}
  static ModInt inv(ModInt x) {return x^^(MD-2);}
  string toString() const {return v.to!string;}
  auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}

  static long[] factorials = [1], invFactorials = [1];
  static void provisionFactorial(int limit) {
    if (factorials.length >= limit) return;

    auto l = factorials.length;
    factorials.length = limit;
    invFactorials.length = limit;
    foreach(i; l..limit) {
      factorials[i] = (factorials[i - 1] * i) % MD;
      invFactorials[i] = pow(factorials[i], MD - 2) % MD;
    }
  }
  static ModInt factorial(int n) {
    provisionFactorial(n + 1);
    return ModInt(factorials[n]);
  }
  static ModInt combine(int n, int k) {
    if (n < k) return ModInt(1);
    provisionFactorial(n + k + 1);
    return ModInt(factorials[n] * invFactorials[k] % MD * invFactorials[n - k] % MD);
  }
  static ModInt combineNaive(long n, long k) {
    if (k < 0 || k > n) return ModInt(0);
    
    ModInt ret = ModInt(1);
    k = min(k, n - k);

    foreach(x; 0..k) {
      ret *= ModInt(n) - ModInt(x);
      ret /= ModInt(x + 1);
    }
    return ret;
  }
}
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

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}


ulong[] primeFactoring(ulong target)
{
  ulong s = target.to!float.sqrt().floor.to!ulong;
  ulong num = target;
  ulong[] primes;
	for (ulong i = 2; i <= s; i++) {
    if (num % i != 0) continue;

		while (num%i == 0) num /= i;
    primes ~= i;
	}
  if (num > s) primes ~= num;
	return primes;
}

bool[] enumeratePrimes(long max)
{
  auto primes = new bool[](max + 1);
  primes[] = true;
  primes[0] = false;
  primes[1] = false;
  foreach (i; 2..max+1) {
    if (primes[i]) {
      auto x = i*2;
      while (x <= max) {
        primes[x] = false;
        x += i;
      }
    }
  }

  return primes;
}

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
    memo = new int[][](lim + 1, 0);

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

  int lpf(int x) {
    int ret = 1;
    while(x > 1) {
      ret = max(ret, spf[x]);
      x /= spf[x];
    }
    return ret;
  }

  int[][] memo;
  int[] divisors(int num) {
    if (num <= 1) return [1];
    if (!memo[num].empty) return memo[num];

    auto p = lpf(num);
    int t; for(auto n = num; n % p == 0; n /= p) t++;
    auto pres = this.divisors(num / (p ^^ t));
    
    int[] ret;
    foreach(c; 0..t + 1) {
      ret ~= pres.map!(pre => pre * (p ^^ c)).array;
    }
    ret.sort!"a > b";
    return memo[num] = ret;
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