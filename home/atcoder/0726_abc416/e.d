void main() { runSolver(); }

void problem() {
  auto N = scan!int();
  auto M = scan!int();
  auto ABC = scan!long(3 * M).chunks(3).array;
  auto K = scan!int();
  auto T = scan!int();
  auto D = scan!int(K).map!"a - 1";
  auto Q = scan!int();

  auto solve() {
    long[][] dists = (long.max / 3).repeat(N^^2).array.chunks(N).array;
    foreach(i; 0..N) dists[i][i] = 0;
    foreach(a, b, c; ABC.asTuples!3) {
      dists[a - 1][b - 1].chmin(c);
      dists[b - 1][a - 1].chmin(c);
    }
    foreach(a; D) foreach(b; D) {
      dists[a][b].chmin(T);
    }

    long[][] ans = (long.max / 3).repeat(N^^2).array.chunks(N).array;
    foreach(i; 0..N) ans[i][i] = 0;

    alias Item = Tuple!(int, "node", long, "cost");
    auto heaps = N.iota.map!(i => [Item(i, 0)].heapify!"a.cost > b.cost").array;

    void update() {
      foreach(from, ref heap; zip(N.iota, heaps)) {
        while(!heap.empty) {
          auto cur = heap.front;
          heap.removeFront;
          if (ans[from][cur.node] != cur.cost) continue;

          foreach(to; 0..N) {
            auto cost = ans[from][cur.node] + dists[cur.node][to];
            if (!ans[from][to].chmin(cost)) continue;

            heap.insert(Item(to, cost));
          }
        }
      }
    }

    update();
    auto airHubs = D.redBlackTree;
    foreach(_; 0..Q) {
      auto QT = scan!int;
      if (QT == 1) {
        auto X = scan!int - 1;
        auto Y = scan!int - 1;
        auto T = scan!long;
        dists[X][Y].chmin(T);
        dists[Y][X].chmin(T);
        foreach(i; 0..N) {
          heaps[i].insert(Item(X, ans[i][X]));
          heaps[i].insert(Item(Y, ans[i][Y]));
        }
        update();
      } else if (QT == 2) {
        auto X = scan!int - 1;
        if (X in airHubs) continue;

        int[] updated = [X];
        foreach(air; airHubs) {
          dists[X][air].chmin(T);
          if (dists[air][X].chmin(T)) updated ~= air;
        }
        foreach(i; 0..N) foreach(u; updated) {
          heaps[i].insert(Item(u, ans[i][u]));
        }
        update();
        airHubs.insert(X);
      } else {
        writeln(ans.joiner.filter!(a => a < long.max / 3).sum);
      }
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

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}
