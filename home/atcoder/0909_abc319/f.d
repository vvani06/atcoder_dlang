void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto T = scan!long(N * 4 - 4).chunks(4).array;

  auto solve() {
    alias Node = Tuple!(int, "p", long, "t", long, "s", long, "g", int, "dragId");
    auto graph = new Node[][](N, 0);
    auto nodes = new Node[](N);
    auto drags = new Node[](0);
    foreach(i, t; T) {
      auto node = Node(i.to!int + 1, t[1], t[2], t[3], -1);
      if (t[1] == 2) {
        node.dragId = drags.length.to!int;
        drags ~= node;
      }

      nodes[i + 1] = node;
      graph[t[0] - 1] ~= node;
    }

    struct State {
      long power;
      int dragsUsed;
      bool[] visited = [false];
      int[] availableDrags;

      this(long p, int d, bool[] v) {
        power = p;
        dragsUsed = d;
        visited = v.dup;
        walk();
        power = min(power, 10L^^9);
      }

      void walk() {
        auto queue = new Node[](0).heapify!"a.s > b.s";
        foreach(n, v; visited.enumerate(0).filter!"a[1]") {
          foreach(next; graph[n]) {
            if (!visited[next.p]) queue.insert(next);
          }
        }

        while(!queue.empty) {
          auto p = queue.front;
          queue.removeFront;
          if (p.s > power) break;

          if (p.t == 1) {
            power += p.g;
            visited[p.p] = true;
            foreach(next; graph[p.p]) queue.insert(next);
          } else {
            availableDrags ~= p.dragId;
          }
        }
      }

      State takeDrag(int d) {
        auto drag = drags[d];
        auto newState = State();
        newState.power = min(10L^^9, power * drag.g);
        newState.visited = visited.dup;
        newState.visited[drag.p] = true;
        newState.dragsUsed = dragsUsed | (1 << d);
        newState.walk();
        newState.power = min(newState.power, 10L^^9);
        return newState;
      }

      int opCmp(State other) {
        return cmp([power], [other.power]);
      }
    }

    auto states = new State[](1 << drags.length);
    states[0] = State(1, 0, true ~ false.repeat(N - 1).array);

    foreach(from; 0..states.length.to!int) {
      auto stateFrom = states[from];
      if (stateFrom.power == 0) continue;

      foreach(d; stateFrom.availableDrags) {
        auto to = from | (1 << d);
        auto stateTo = stateFrom.takeDrag(d);
        // deb([from, d], stateTo);
        states[to] = max(states[to], stateTo);
      }
    }

    return !states[$ - 1].visited.canFind(false);
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
