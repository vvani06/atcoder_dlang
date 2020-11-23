void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto Caa = scan;
  auto Cab = scan;
  auto Cba = scan;
  auto Cbb = scan;

  void testPrint() {
    string[string] C;
    C["AA"] = "A" ~ Caa ~ "A";
    C["AB"] = "A" ~ Cab ~ "B";
    C["BA"] = "B" ~ Cba ~ "A";
    C["BB"] = "B" ~ Cbb ~ "B";

    string[] SS = ["AB"];
    foreach(i; 0..N-2) {
      string[] next;
      foreach(s; SS) {
        foreach(x; 0..1+i) {
          next ~= s[0..x] ~ C[s[x..x+2]] ~ s[x+2..$];
        }
      }
      SS = next.sort.uniq.array;
    }
    SS.length.deb;
    SS.deb;
  }

  MInt1 solve() {
    if (Caa == "A" && Cab == "A") {
      return MInt1(1);
    }
    if (Cab == "B" && Cbb == "B") {
      return MInt1(1);
    }

    MInt1 ans;
    string z = Caa ~ Cab ~ Cba ~ Cbb;
    if (z == "ABAA" || z == "BABA" || z == "BBAA" || z == "BABB") {
      // 32
      ans = MInt1(1);
      if (N > 3) ans = MInt1(2) ^^ (N-3);
      return ans;
    }
    if (z == "ABBA" || z == "BAAA" || z == "BAAB" || z == "BBBA") {
      // 13;
      MInt1[] acc;
      acc.length = N;
      acc[0] = MInt1(0);
      acc[1] = MInt1(1);
      foreach(i; 2..N) {
        acc[i] = acc[i-1] + acc[i-2];
      }
      acc.deb;
      return acc[$-1];
    }
    return MInt1(0);
  }

  debug testPrint();
  solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

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
