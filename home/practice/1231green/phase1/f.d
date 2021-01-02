void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto A = scan!long(N);

  long solve() {
    long[long] midL;
    long[long] midR;

    foreach(i, a; A) {
      long x = a + i;
      midL.require(x, 0);
      midR.require(x, 0);
      midL[x]++;
    }

    foreach(i, a; A) {
      long x = i - a;
      midL.require(x, 0);
      midR.require(x, 0);
      midR[x]++;
    }

    long ans;
    foreach(x; midL.keys) {
      ans += midL[x] * midR[x];
    }

    return ans;
  }

  solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.bigint, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
alias Person = Tuple!(long, "number", long, "height");

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

enum MOD1 = 10^^9 + 7;
alias MInt1 = ModInt!(MOD1);

enum MOD9 = 998_244_353;
alias MInt9 = ModInt!(MOD9);
