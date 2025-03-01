void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto G = scan!string(N);
  
  bool isParindrome(string s) {
    return s.retro.to!string == s;
  }

  alias labels = Tuple!(dchar, "label", bool, "wild");

  auto solve() {
    alias Edge = int[][dchar];
    auto graph = new Edge[](N);
    auto revGraph = new Edge[](N);
    foreach(i, s; G) {
      foreach(j, c; s) {
        graph[i][c] ~= j.to!int;
        revGraph[j][c] ~= i.to!int;
      }
    }

    foreach(i; 0..N) {
      int[] ans;

      foreach(j; 0..N) {
        int tAns = int.max;
        bool[][] visited = new bool[][](N + 10, N + 1);

        void dfs(int s, int g, int step, dchar pre) {
          if (s == g) {
            tAns = min(tAns, step);
            return;
          }
          if (step >= N) return;

          foreach(dchar c; 'a'..'z' + 1) {
            if (!(c in graph[s]) || !(c in revGraph[g])) continue;

            foreach(sn; graph[s][c]) foreach(gn; revGraph[g][c]) {
              if (sn == s && gn == g) continue;
              if (pre == c && (sn == s || gn == g)) continue;
              
              if (sn == g || gn == s) {
                tAns = min(tAns, step + 1);
              } else {
                if (visited[step + 2][sn] && visited[step + 2][gn]) {} else {
                visited[step + 2][sn] = visited[step + 2][gn] = true;
                dfs(sn, gn, step + 2, c);
                }
              }
            }
          }
        }

        dfs(i, j, 0, 0);
        ans ~= tAns == int.max ? -1 : tAns;
      }

      writefln("%(%s %)", ans);
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
struct ModInt(uint MD) if (MD < int.max) {ulong v;this(string v) {this(v.to!long);}this(int v) {this(long(v));}this(long v) {this.v = (v%MD+MD)%MD;}void opAssign(long t) {v = (t%MD+MD)%MD;}static auto normS(ulong x) {return (x<MD)?x:x-MD;}static auto make(ulong x) {ModInt m; m.v = x; return m;}auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r.v));}auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r.v));}auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r.v%MD).to!ulong);}auto opBinary(string op:"^^", T)(T r) const {long x=v;long y=1;while(r){if(r%2==1)y=(y*x)%MD;x=x^^2%MD;r/=2;} return make(y);}auto opBinary(string op:"/")(ModInt r) const {return this*memoize!inv(r);}static ModInt inv(ModInt x) {return x^^(MD-2);}string toString() const {return v.to!string;}auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}}
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
      static if (isInputRange!A) ret ~= rets.joiner("\n").to!string; else ret ~= rets.joiner("\n").to!string; 
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

struct Eratosthenes {
  bool[] isPrime;
  int[] rawPrimes;
  int[] spf;

  this(int lim) {
    isPrime = new bool[](lim + 1);
    isPrime[2..$] = true;
    spf = new int[](lim + 1);
    spf[] = int.max;
    spf[0..2] = 1;
    memo = new int[][](lim + 1, 0);

    foreach (i; 2..lim+1) {
      if (isPrime[i]) {
        spf[i] = i;

        auto x = i*2;
        while (x <= lim) {
          isPrime[x] = false;
          spf[x].chmin(i);
          x += i;
        }
      }
    }

    foreach(p; 2..lim + 1) {
      if (isPrime[p]) rawPrimes ~= p;
    }
  }

  auto primes() { return rawPrimes.assumeSorted; }

  int[int] factorize(int x) {
    int[int] ret;
    while(x > 1) {
      ret[spf[x]]++;
      x /= spf[x];
    }
    return ret;
  }

  int lpf(int x) {
    int ret = 1;
    while(x > 1) {
      ret = max(ret, spf[x]);
      x /= spf[x];
    }
    return ret;
  }

  int[][] memo;
  int[] divisors(int num) {
    if (num <= 1) return [1];
    if (!memo[num].empty) return memo[num];

    auto p = lpf(num);
    int t; for(auto n = num; n % p == 0; n /= p) t++;
    auto pres = this.divisors(num / (p ^^ t));
    
    int[] ret;
    foreach(c; 0..t + 1) {
      ret ~= pres.map!(pre => pre * (p ^^ c)).array;
    }
    ret.sort!"a > b";
    return memo[num] = ret;
  }
}
