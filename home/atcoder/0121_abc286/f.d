void main() { runSolver(); }

void problem() {

  auto solve() {
    auto N = scan!int;

    int[] conv(int m, int[] arr) {
      auto ret = iota(1, m + 1).array;
      foreach(_; 0..N) {
        auto t = new int[](m);
        foreach(i; 0..m) {
          t[i] = arr[ret[i] - 1];
        }
        // t.deb;
        ret = t;
      }

      return ret;
    }

    long[] seeds = [2, 3, 5, 7, 11, 13, 17, 19, 23];
    const M = seeds.sum.to!int;
    int[][] A;
    int offset = 1;
    foreach(s; seeds) {
      A ~= iota(offset + 1, offset + s.to!int).array ~ offset;
      offset += s;
    }
    M.writeln;
    stdout.flush;
    A.joiner.toAnswerString.writeln;
    stdout.flush;

    // conv(M, A.joiner.array).toAnswerString.deb;
    auto response = scan!int(M);
    int[][] B;
    offset = 0;
    foreach(s; seeds) {
      B ~= response[offset..offset + s];
      offset += s;
    }

    long[] shifts;
    foreach(a, b; zip(A, B)) {
      shifts ~= b.countUntil(a[0]);
    }
    
    auto ans = crt(seeds, shifts);
    ans[0].writeln;
    stdout.flush;

    // long s;
    // long m = 1;
    // foreach(n; [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]) {
    //   s += n;
    //   m *= n;
    //   deb([n, s, m]);
    //   if (m >= 10^^9) "YES".deb;
    // }
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std, core.bitop;
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

Tuple!(long, long) inv_gcd(long a, long b) {
  a = (a % b + b) % b;
  if (a == 0) return tuple(b, 0L);

  auto s = b, t = a;
  long m0 = 0, m1 = 1;
  
  while(t) {
    const u = s / t;
    s -= t * u;
    m0 -= m1 * u;

    swap(s, t);
    swap(m0, m1);
  }

  if (m0 < 0) m0 += b / s;
  return tuple(s, m0);
}

Tuple!(long, long) crt(long[] r, long[] m) {
  assert(r.length == m.length);

  int n = r.length.to!int;
  long r0 = 0, m0 = 1;
  for(int i = 0; i < n; i++) {
    assert(1 <= m[i]);
    auto r1 = (r[i] % m[i] + m[i]) % m[i];
    auto m1 = m[i];
    if (m0 < m1) {
      swap(r0, r1);
      swap(m0, m1);
    }
    if (m0 % m1 == 0) {
      if (r0 % m1 != r1) return tuple(0L, 0L);
      continue;
    }

    const ig = inv_gcd(m0, m1);
    const g = ig[0], im = ig[1];

    const u1 = m1 / g;
    if ((r1 - r0) % g) return tuple(0L, 0L);

    const x = (r1 - r0) / g % u1 * im % u1;
    r0 += x * m0;
    m0 *= u1;
    if (r0 < 0) r0 += m0;
  }

  return tuple(r0, m0);
}
