void main() {
  problem();
}

void problem() {
  auto N = scan!ulong;
  auto M = scan!ulong;
  auto K = scan!ulong;

  auto solve() {
    MInt9 ans;

    MInt9 allPatterns = MInt9(K)^^(N*M);
    allPatterns.deb;

    MInt9 patterns(ulong a, ulong b, ulong size) {
      MInt9 ret = MInt9(max(a, b) - min(a, b) + 1);
      return ret ^^ (size - 1) * MInt9(size) - MInt9(size - 1);
    }

    foreach(minA; 1..K + 1) {
      [patterns(1, minA, N), patterns(K, minA, M)].deb;
      allPatterns -= patterns(1, minA, N) * patterns(K, minA, M);
    }

    return allPatterns;
  }

  static if (is(ReturnType!(solve) == void)) solve(); else solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct ModInt(uint MD) if (MD < int.max) {
  ulong v;
  this(int v) {this(long(v));}
  this(long v) {this.v = (v%MD+MD)%MD;}
  static auto normS(ulong x) {return (x<MD)?x:x-MD;}
  static auto make(ulong x) {ModInt m; m.v = x; return m;}
  auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r.v));}
  auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r.v));}
  auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r.v%MD).to!ulong);}
  auto opBinary(string op:"^^", T)(T r) const {long x=v;long y=1;while(r){if(r%2==1)y=(y*x)%MD;x=x^^2%MD;r/=2;} return make(y);}
  auto opBinary(string op:"/")(ModInt r) const {return this*inv(r);}
  static ModInt inv(ModInt x) {return x^^(MD-2);};
  string toString() const {return v.to!string;}
  auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}
}

alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);