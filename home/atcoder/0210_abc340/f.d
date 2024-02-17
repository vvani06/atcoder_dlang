void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto E = scan!int(3 * M).chunks(3);

  auto solve() {
    enum bitnums = 20.iota.map!"2 ^^ a".array;
    enum INF = long.max / 3;

    struct Edge {
      int from, to;
      long cost;
    }

    Edge[][] graph = new Edge[][](N, 0);
    foreach(e; E) {
      e[0]--; e[1]--;
      graph[e[0]] ~= Edge(e[0], e[1], e[2]);
    }

    struct Path {
      int to;
      long cost = INF;
      int[] route;

      int opCmp(Path other) {
        return cmp(
          [cost], [other.cost]
          // [cost, route.popcnt],
          // [other.cost, other.route.popcnt]
        );
      }
    }

    Path[][] shortest = new Path[][](N, 0);
    foreach(f; 0..N) {
      Path[] bests = new Path[](N);
      bests[f] = Path(f, 0, [0]);

      for(auto queue = [bests[f]].heapify!"a > b"; !queue.empty;) {
        auto cur = queue.front;
        queue.removeFront;
        if (cur != bests[cur.to]) continue;

        foreach(e; graph[cur.to]) {
          auto cost = cur.cost + e.cost;
          foreach(r; cur.route) {
            auto route = r | bitnums[e.to];
            if (cost < bests[e.to].cost) {
              bests[e.to] = Path(e.to, cost, [route]);
              queue.insert(bests[e.to]);
            }
          }
        }
      }
      shortest[f] = bests;
    }
    auto dp = new long[][](2^^N, N);
    foreach(ref d; dp) d[] = INF;
    foreach(f, b; bitnums[0..N]) dp[b][f] = 0;
    foreach(fromState; 0..2^^N - 1) {
      foreach(from; 0..N) {
        if ((bitnums[from] & fromState) == 0) continue;
        if (dp[fromState][from] == INF) continue;

        foreach(to; 0..N) {
          if ((bitnums[to] & fromState) != 0) continue;

          auto path = shortest[from][to];
          if (path.route.empty) continue;
          foreach(r; path.route) {
            auto toState = fromState | bitnums[to];
            dp[toState][to].chmin(dp[fromState][from] + path.cost);
          }
        }
      }
    }

    return dp[$ - 1].minElement == INF ? "No" : dp[$ - 1].minElement.to!string;
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
