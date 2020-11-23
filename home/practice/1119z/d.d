void main() {
  problem();
}

void problem() {
  auto S = scan;

  void solve() {
    auto sizes = SList!ulong();
    {
      auto stack = SList!ulong();
      foreach(i, c; S) {
        if (c == '(') {
          stack.insert(i);
        } else {
          sizes.insert(i - stack.front + 1);
          stack.removeFront;
        }
      }
    }

    auto pows = new MInt1[sizes.reduce!max + 1];
    pows[0] = 1;
    foreach(i; 1..pows.length) {
      pows[i] = (pows[i-1] * 2) % MOD1;
    }

    MInt1 ans = 1;
    foreach(s; sizes) {
      ans *= pows[s];
    } 

    ans.writeln;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.bigint, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

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
