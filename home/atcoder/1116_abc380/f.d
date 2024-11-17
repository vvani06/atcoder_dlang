void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto L = scan!int;
  auto A = scan!int(N);
  auto B = scan!int(M);
  auto C = scan!int(L);

  auto solve() {
    auto ALL = N + M + L;
    auto CARDS = 0 ~ A ~ B ~ C;
    enum ALL_STATES = 3^^13;

    int[] cards(int state, int x) {
      state /= 3;

      int[] ret;
      foreach(i; 0..ALL) {
        if (state % 3 == x) ret ~= i + 1;
        state /= 3;
      }
      return ret;
    }

    int initState = 3 * (iota(N, N + M).map!"3^^a".sum + iota(N + M, ALL).map!"2 * 3^^a".sum);

    int[][] graph = new int[][](ALL_STATES, 0);
    int[][] revGraph = new int[][](ALL_STATES, 0);
    void connect(int from, int to) {
      graph[from] ~= to;
      revGraph[to] ~= from;
      // deb("connect: ", [from, to]);
    }

    auto visited = new bool[](ALL_STATES);
    for(auto queue = DList!int(initState); !queue.empty;) {
      auto from = queue.front;
      queue.removeFront;

      if (visited[from]) continue;
      visited[from] = true;

      auto player = from % 3;
      auto next = from - player + (player ^ 1);
      // [from, player].deb;
      foreach(drop; cards(from, player)) {
        auto dropped = next - player*3^^drop + 2*3^^drop;
        connect(from, dropped);
        queue.insertBack(dropped);

        foreach(pick; cards(from, 2)) {
          if (CARDS[pick] >= CARDS[drop]) continue;

          auto picked = dropped + player*3^^pick - 2*3^^pick;
          connect(from, picked);
          queue.insertBack(picked);
        }
      }
    }

    bool[] win = new bool[](ALL_STATES);
    int[] rest = new int[](ALL_STATES);
    auto queue = DList!int();
    foreach(state, nexts; graph.enumerate(0)) {
      if (!visited[state]) continue;

      if (nexts.empty()) {
        win[state] = state % 3 == 1;
        queue.insertBack(state);
      } else {
        rest[state] = nexts.length.to!int;
      }
    }

    while(!queue.empty) {
      auto cur = queue.front;
      queue.removeFront;

      foreach(next; revGraph[cur]) {
        rest[next]--;
        if (rest[next] == 0) queue.insertBack(next);
      }

      if (cur % 3 == 0) {
        win[cur] = graph[cur].any!(s => win[s]);
      } else {
        win[cur] = graph[cur].all!(s => win[s]);
      }
    }

    return win[initState] ? "Takahashi" : "Aoki";
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
