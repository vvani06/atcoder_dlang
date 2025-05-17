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
}

// struct ModInt(uint MD) if (MD < int.max) {ulong v;this(string v){this(v.to!long);}this(int v){this(long(v));}this(long v){this.v=(v%MD+MD)%MD;}void opAssign(long t){v=(t%MD+MD)%MD;}static auto normS(ulong x){return(x<MD)?x:x-MD;}static auto make(ulong x){ModInt m;m.v=x;return m;}auto opBinary(string op:"+")(ModInt r)const{return make(normS(v+r.v));}auto opBinary(string op:"-")(ModInt r)const{return make(normS(v+MD-r.v));}auto opBinary(string op:"*")(ModInt r)const{return make((ulong(v)*r.v%MD).to!ulong);}static long pow(long x,long n){long ans=1;while(n>0){if((n&1)==1){ans=ans*x%MD;}x=x*x%MD;n>>=1;}return ans;}auto opBinary(string op:"^^",T)(T r)const{return make(pow(v,r));}auto opBinary(string op:"/")(ModInt r)const{return this*memoize!inv(r);}static ModInt inv(ModInt x){return x^^(MD-2);}string toString()const{return v.to!string;}auto opOpAssign(string op)(ModInt r){return mixin("this=this"~op~"r");}static long[] factorials=[1],invFactorials=[1];static void provisionFactorial(int limit){if(factorials.length>=limit)return;auto l=factorials.length;factorials.length=limit;invFactorials.length=limit;foreach(i;l..limit){factorials[i]=(factorials[i-1]*i)%MD;invFactorials[i]=pow(factorials[i],MD-2)%MD;}}static ModInt factorial(int n){provisionFactorial(n+1);return ModInt(factorials[n]);}static ModInt combine(int n,int k){if(n<k)return ModInt(1);provisionFactorial(n+k+1);return ModInt(factorials[n]*invFactorials[k]%MD*invFactorials[n-k]%MD);}}
alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);
