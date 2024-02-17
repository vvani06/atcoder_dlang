void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto E = scan!int(2 * M).chunks(2);
  auto W = scan!int(N);
  auto A = scan!int(N);

  auto solve() {
    auto graph = new int[][](N, 0);
    auto revGraph = new int[][](N, 0);
    auto connected = new int[][](N, 0).map!redBlackTree;
    auto inCounts = new int[](N);
    auto outCounts = new int[](N);
    
    foreach(e; E) {
      auto f = e[0] - 1;
      auto t = e[1] - 1;
      if (W[f] < W[t]) {
        graph[f] ~= t;
        inCounts[t]++;
      }
      if (W[f] > W[t]) {
        revGraph[t] ~= f;
        outCounts[t]++;
      }
    }

    auto perf = W.map!(w => Rational(1, w)).array;
    auto used = new long[](N);
    for(auto queue = DList!int(N.iota.filter!(i => inCounts[i] == 0)); !queue.empty;) {
      auto p = queue.front;
      queue.removeFront;
      
      foreach(next; graph[p]) {
        if (used[next] + W[p] >= W[next]) continue;

        used[next] += W[p];
        perf[next].u++;
        connected[next].insert(p);
        if (--inCounts[next] == 0) queue.insert(next);
      }
    }

    long ans;
    for(auto queue = DList!int(N.iota.filter!(i => outCounts[i] == 0)); !queue.empty;) {
      auto p = queue.front;
      queue.removeFront;

      [p].deb;
      ans += A[p];
      
      foreach(next; revGraph[p]) {
        if (next in connected[p]) {
          A[next] += A[p];
        }
        if (--outCounts[next] == 0) queue.insert(next);
      }
    }

    return ans;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
import core.bitop;
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
  else if (is(T == string)) fn().writeln;
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

struct Rational {
  long u, l = 1;
  this(long u) { this.u = u; }
  this(long u, long l) {
    if (l == 0) assert("lower number cannot be 0");

    if (l < 0) {
      u *= -1;
      l *= -1;
    }
    const g = gcd(u.abs, l);
    this.u = u / g;
    this.l = l / g;
  }

  Rational add(Rational o) {
    const nl = l * o.l;
    const nu = u * o.l + o.u * l;
    return Rational(nu, nl);
  }
  Rational sub(Rational o) { return add(Rational(-o.u, o.l)); }
  Rational mul(Rational o) { return Rational(u * o.u, l * o.l); }
  Rational div(Rational o) { return Rational(u * o.l, l * o.u); }

  Rational opBinary(string op: "+")(Rational o) { return add(o); }
  Rational opBinary(string op: "-")(Rational o) { return sub(o); }
  Rational opBinary(string op: "*")(Rational o) { return mul(o); }
  Rational opBinary(string op: "/")(Rational o) { return div(o); }
  void opAssign(T)(t v) { u = v; }

  int opCmp(Rational o) {
    const me = u * o.l;
    const other = o.u * l;
    return me > other ? 1 : me < other ? -1 : 0;
  }
}
