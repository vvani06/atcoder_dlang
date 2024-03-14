void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto P = scan!long(N * N).chunks(N).array;
  auto R = scan!long(N * N - N).chunks(N - 1).array;
  auto D = scan!long(N * N - N).chunks(N).array;

  auto solve() {
    struct Memo {
      static long[long] empty;
      long[long][long] m;

      void add(long maxEarn, long step, long money) {
        m.require(maxEarn, empty.dup);

        auto s = m[maxEarn].keys;
        if (s.empty) {
          m[maxEarn][step] = money;
        } else if (s[0] > step) {
          m[maxEarn].clear;
          m[maxEarn][step] = money;
        } else if (s[0] == step) {
          m[maxEarn][step].chmin(money);
        }
      }
    }

    auto memo = new Memo[][](N, N);
    memo[0][0] = Memo();
    memo[0][0].add(P[0][0], 0, 0);

    struct Coord { int x, y; }
    bool[Coord] queued;
    
    for(auto queue = DList!Coord(Coord(0, 0)); !queue.empty;) {
      auto p = queue.front; queue.removeFront;

      foreach(maxEarn, kv; memo[p.x][p.y].m) foreach(step, money; kv) {
        alias Move = Tuple!(Coord, long);
        Move[] moves;
        if (p.x < N - 1) moves ~= Move(Coord(p.x + 1, p.y), money - D[p.x][p.y]);
        if (p.y < N - 1) moves ~= Move(Coord(p.x, p.y + 1), money - R[p.x][p.y]);
        // moves.deb;

        foreach(move; moves) {
          auto coord = move[0];
          auto movedMoney = move[1];
          auto earn = max(maxEarn, P[coord.x][coord.y]);
          long addStep = movedMoney < 0 ? (movedMoney.abs + earn - 1) / earn : 0;

          memo[coord.x][coord.y].add(max(maxEarn, P[coord.x][coord.y]), step + addStep, movedMoney + addStep * earn);
          if (!(coord in queued)) {
            queue.insertBack(coord);
            queued[coord] = true;
          }
        }
      }
    }

    return memo[N - 1][N - 1].m.values.map!"a.keys.minElement".minElement + N*2 - 2;
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
