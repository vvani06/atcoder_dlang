
struct ModInt(uint MD) if (MD < int.max) {
  ulong v;
  this(int v) {this(long(v));}
  this(long v) {this.v = (v%MD+MD)%MD;}
  static auto normS(ulong x) {return (x<MD)?x:x-MD;}
  static auto make(ulong x) {ModInt m; m.v = x; return m;}
  auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r));}
  auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r));}
  auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r.v%MD).to!ulong);}
  auto opBinary(string op:"^^", T)(T r) const {long x=v;long y=1;while(r){if(r%2==1)y=(y*x)%MD;x=x^^2%MD;r/=2;} return make(y);}
  auto opBinary(string op:"/")(ModInt r) const {return this*inv(r);}
  static ModInt inv(ModInt x) {return x^^(MD-2);};
  string toString() const {return v.to!string;}
  auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}
}

alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);
