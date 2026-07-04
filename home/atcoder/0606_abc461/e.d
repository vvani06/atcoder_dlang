void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto Q = iota(scan!int).map!(i => tuple(i + 1, scan!int, scan!int)).array;

  auto solve() {
    auto segtreeB = SegTree!("a + b", int)(new int[](Q.length + 10));
    auto segtreeW = SegTree!("a + b", int)(new int[](Q.length + 10));
    auto posB = (N + 1).iota.map!(_ => new int[](0).heapify).array;
    auto posW = (N + 1).iota.map!(_ => new int[](0).heapify).array;
    auto filledB = new bool[](N);
    auto filledW = new bool[](N);
    filledW[] = true;

    long ans;
    foreach(i, t, x; Q.asTuples!3) {
      x--;

      if (t == 1) {
        segtreeB.update(i, posB[x].empty);
        if (filledB[x]) {
          ans += segtreeW.sum(posB[x].empty ? 0 : posB[x].front, i);
        } else {
          ans += N;
          filledB[x] = true;
        }
        posB[x].insert(i);
      } else {
        segtreeW.update(i, posW[x].empty);
        ans -= segtreeB.sum(posW[x].empty ? 0 : posW[x].front, i);
        posW[x].insert(i);
      }

      writeln(ans);
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

struct SegTree(alias pred = "a + b", T = long) {
  alias predFun = binaryFun!pred;
  int size;
  T[] data;
  T monoid;

  T op(T a, T b) {
    if (a == monoid) return b;
    if (b == monoid) return a;
    return predFun(a, b);
  }
 
  this(T[] src, T monoid = T.init) {
    this.monoid = monoid;

    for(int i = 2; i < 2L^^32; i *= 2) {
      if (src.length <= i) {
        size = i;
        break;
      }
    }
    
    data = new T[](size * 2);
    foreach(i, s; src) data[i + size] = s;
    foreach_reverse(b; 1..size) {
      data[b] = op(data[b * 2], data[b * 2 + 1]);
    }
  }
 
  void update(int index, T value) {
    int i = index + size;
    data[i] = value;
    while(i > 0) {
      i /= 2;
      data[i] = op(data[i * 2], data[i * 2 + 1]);
    }
  }

  void add(int index, T value) {
    update(index, op(get(index), value));
  }
 
  T get(int index) {
    return data[index + size];
  }
 
  T sum(int a, int b, int k = 1, int l = 0, int r = -1) {
    if (r < 0) r = size;
    
    if (r <= a || b <= l) return monoid;
    if (a <= l && r <= b) return data[k];
 
    T leftValue = sum(a, b, 2*k, l, (l + r) / 2);
    T rightValue = sum(a, b, 2*k + 1, (l + r) / 2, r);
    return op(leftValue, rightValue);
  }

  T[] array() {
    return size.iota.map!(i => get(i)).array;
  }

  static if (__traits(hasMember, T, "opCmp")) {
    int lowerBound(T border) {
      return binarySearch((int t) => sum(0, t) < border, 0, size + 1);
    }

    int upperBound(T border) {
      return binarySearch((int t) => sum(t, size) < border, size, -1);
    }
  }

  private K binarySearch(K)(bool delegate(K) cond, K l, K r) { return binarySearch((K k) => k, cond, l, r); }
  private T binarySearch(T, K)(K delegate(T) fn, bool delegate(K) cond, T l, T r) {
    auto ok = l;
    auto ng = r;
    const T TWO = 2;
  
    bool again() {
      static if (is(T == float) || is(T == double) || is(T == real)) {
        return !ng.approxEqual(ok, 1e-08, 1e-08);
      } else {
        return abs(ng - ok) > 1;
      }
    }
  
    while(again()) {
      const half = (ng + ok) / TWO;
      const halfValue = fn(half);
  
      if (cond(halfValue)) {
        ok = half;
      } else {
        ng = half;
      }
    }
  
    return ok;
  }
}

long countInvertions(T)(T[] arr) {
  auto segtree = SegTree!("a + b", long)(new long[](arr.length));
  long ret;
  long pre = -1;
  int[] adds;
  foreach(a; arr.enumerate(0).array.sort!"a[1] > b[1]") {
    auto i = a[0];
    auto n = a[1];
    if (pre != n) {
      foreach(ai; adds) segtree.update(ai, segtree.get(ai) + 1);   
      adds.length = 0;
    }
    adds ~= i;
    pre = n;
    ret += segtree.sum(0, i);
  }
  return ret;
}
