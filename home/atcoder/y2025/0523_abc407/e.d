void main() { runSolver(); }

void problem() {
  auto T = scan!int;

  auto subSolve(long N, long[] A) {
    RedBlackTree!int[long] indicies;
    auto rbt = A[1..$ - 1].redBlackTree!true;
    foreach(i, a; A[1..$ - 1]) {
      indicies.require(a, new int[](0).redBlackTree);
      indicies[a].insert(i.to!int);
    }

    long ans = A[0];
    foreach(_; 0..N - 1) {
      auto u = rbt.back;
      auto ui = indicies[u].front;
      auto l = rbt.front;
      auto li = indicies[l].back;
      rbt.removeKey(u, l);
      ans += u;
    }
    return ans;
  }

  auto solve() {
    foreach(_; 0..T) {
      auto n = scan!long;
      writeln(subSolve(n, scan!long(n * 2)));
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
struct ModInt(uint MD) if (MD < int.max) {ulong v;this(string v){this(v.to!long);}this(int v){this(long(v));}this(long v){this.v=(v%MD+MD)%MD;}void opAssign(long t){v=(t%MD+MD)%MD;}static auto normS(ulong x){return(x<MD)?x:x-MD;}static auto make(ulong x){ModInt m;m.v=x;return m;}auto opBinary(string op:"+")(ModInt r)const{return make(normS(v+r.v));}auto opBinary(string op:"-")(ModInt r)const{return make(normS(v+MD-r.v));}auto opBinary(string op:"*")(ModInt r)const{return make((ulong(v)*r.v%MD).to!ulong);}static long pow(long x,long n){long ans=1;while(n>0){if((n&1)==1){ans=ans*x%MD;}x=x*x%MD;n>>=1;}return ans;}auto opBinary(string op:"^^",T)(T r)const{return make(pow(v,r));}auto opBinary(string op:"/")(ModInt r)const{return this*memoize!inv(r);}static ModInt inv(ModInt x){return x^^(MD-2);}string toString()const{return v.to!string;}auto opOpAssign(string op)(ModInt r){return mixin("this=this"~op~"r");}static long[] factorials=[1],invFactorials=[1];static void provisionFactorial(int limit){if(factorials.length>=limit)return;auto l=factorials.length;factorials.length=limit;invFactorials.length=limit;foreach(i;l..limit){factorials[i]=(factorials[i-1]*i)%MD;invFactorials[i]=pow(factorials[i],MD-2)%MD;}}static ModInt factorial(int n){provisionFactorial(n+1);return ModInt(factorials[n]);}static ModInt combine(int n,int k){if(n<k)return ModInt(1);provisionFactorial(n+k+1);return ModInt(factorials[n]*invFactorials[k]%MD*invFactorials[n-k]%MD);}}
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
void deb(T ...)(T t){ debug t.writeln; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
  else asAnswer(fn()).writeln;
}
void runSolver() {
  static import std.datetime.stopwatch;
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
