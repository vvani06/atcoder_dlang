void main() { runSolver(false); }

void problem() {
  auto N = scan!int;
  auto UV = scan!int(2 * N - 2).chunks(2);
  auto C = scan!int(N) ~ 0.repeat(N).array;

  auto solve() {
    auto graph = new int[][](N * 2, 0);
    foreach(u, v, ex; zip(UV.map!"a[0]", UV.map!"a[1]", iota(N, N*2))) {
      graph[u - 1] ~= ex;
      graph[ex] ~= u - 1;
      graph[v - 1] ~= ex;
      graph[ex] ~= v - 1;
    }

    int[] distances(int from) {
      auto ret = new int[](N * 2);
      void dfs(int cur, int pre, int d) {
        ret[cur] = d;
        foreach(next; graph[cur]) {
          if (next == pre) continue;
          dfs(next, cur, d + 1);
        }
      }
      dfs(from, from, 0);
      return ret;
    }

    auto d1 = distances(0);
    auto d2 = distances(d1.maxIndex.to!int);
    auto d3 = distances(d2.maxIndex.to!int);
    auto diameter = d2.maxElement;
    auto half = diameter / 2;
    
    int center;
    foreach(i, di, dj; zip(iota(N * 2), d2, d3)) {
      if (di == half && dj == half) center = i;
    }

    auto nodesByColor = new int[][](N + 1);
    foreach(i, c; C.enumerate(0)) nodesByColor[c] ~= i;
    
    long ans;
    long[int] countByColor;
    long[int] tmpAdd;
    void dfs(int cur, int pre, int d) {
      if (d == half) {
        tmpAdd[C[cur]]++;
        ans += countByColor.get(C[cur], 0);
      }

      foreach(next; graph[cur]) {
        if (next == pre) continue;

        dfs(next, cur, d + 1);
        if (d == 0) {
          foreach(k, v; tmpAdd) countByColor[k] += v;
          tmpAdd.clear;
        }
      }
    }
    dfs(center, center, 0);
    return ans;
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