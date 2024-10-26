void main() { runSolver(); }

void problem() {
  enum INF = long.max / 3;
  auto N = scan!int;
  auto M = scan!int;
  auto QN = scan!int;
  auto E = scan!int(3 * M).chunks(3).array;

  auto solve() {
    bool[int] removed;
    int[][] Q;
    foreach(_; 0..QN) {
      auto t = scan!int;
      if (t == 1) {
        auto rem = scan!int - 1;
        Q ~= [t, rem];
        removed[rem] = true;
      } else {
        Q ~= [t, scan!int - 1, scan!int - 1];
      }
    }

    alias Edge = Tuple!(int, "node", long, "cost");
    Edge[][] graph = new Edge[][](N, 0);
    foreach(i, ref e; E) {
      e[0]--; e[1]--;
      if (i.to!int in removed) continue;

      graph[e[0]] ~= Edge(e[1], e[2]);
      graph[e[1]] ~= Edge(e[0], e[2]);
    }

    long[][] costs = new long[][](N, N);
    foreach(ref c; costs) c[] = INF;
    foreach(i; 0..N) {
      costs[i][i] = 0;
      for(auto queue = [Edge(i, 0)].heapify!"a.cost > b.cost"; !queue.empty;) {
        auto cur = queue.front;
        queue.removeFront;
        if (costs[i][cur.node] != cur.cost) continue;

        foreach(e; graph[cur.node]) {
          auto cost = cur.cost + e.cost;
          if (costs[i][e.node].chmin(cost)) {
            queue.insert(Edge(e.node, cost));
          }
        }
      }
    }

    void add(int[] edge) {
      auto f = edge[0];
      auto t = edge[1];
      graph[f] ~= Edge(t, edge[2]);
      graph[t] ~= Edge(f, edge[2]);

      foreach(i; 0..N) {
        for(auto queue = [Edge(f, costs[i][f]), Edge(t, costs[i][t])].heapify!"a.cost > b.cost"; !queue.empty;) {
          auto cur = queue.front;
          queue.removeFront;
          if (costs[i][cur.node] != cur.cost) continue;

          foreach(e; graph[cur.node]) {
            auto cost = cur.cost + e.cost;
            if (costs[i][e.node].chmin(cost)) {
              queue.insert(Edge(e.node, cost));
            }
          }
        }
      }
    }

    long[] ans;
    foreach(q; Q.reverse) {
      if (q[0] == 1) {
        auto e = E[q[1]];
        add(e);
      } else {
        ans ~= costs[q[1]][q[2]];
      }
    }

    foreach(a; ans.reverse) writeln(a >= INF ? -1 : a);
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
size_t digitSize(T)(T t) { return t.to!string.length; }
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
