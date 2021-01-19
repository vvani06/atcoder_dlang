void main() {
  problem();
}

void problem() {

  long solve(long N, long S, long K) {
    deb("[START]", [N, S, K]);
    
    long B = N - S;
    long A = K;
    long M = N;

    long d = B.gcd(A).gcd(M);
    A /= d;
    B /= d;
    M /= d;

    if (A.gcd(M) != 1) return -1;

    return modInv(A, M) * B;
  }

  const T = scan!long;
  foreach(t; 0..T) {
    const N = scan!long;
    const S = scan!long;
    const K = scan!long;

    solve(N, S, K).writeln;
  }
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------

struct ModInt(uint MD) if (MD < int.max) {
  ulong v;
  alias v this;
  this(int v) {this(long(v));}
  this(long v) {this.v = (v%MD+MD)%MD;}
  static auto normS(ulong x) {return (x<MD)?x:x-MD;}
  static auto make(ulong x) {ModInt m; m.v = x; return m;}
  auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r));}
  auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r));}
  auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r%MD).to!ulong);}
  auto opBinary(string op:"^^", T)(T r) const {long x=v;long y=1;while(r){if(r%2==1)y=(y*x)%MD;x=x^^2%MD;r/=2;} return make(y);}
  auto opBinary(string op:"/")(ModInt r) const {return this*inv(r);}
  static ModInt inv(ModInt x) {return x^^(MD-2);};
  string toString() const {return v.to!string;}
  auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}
}

long modInv(long a, long mod) {
  return a^^(mod-2);
}

alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);
