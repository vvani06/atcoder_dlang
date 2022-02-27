void main() { runSolver(); }

void problem() {
  auto QN = scan!int;

  auto solve() {
    auto subSolve() {
      auto N = scan!long;
      auto A = scan!long(N);

      int[long] numsCount;
      foreach(a; A) numsCount[a]++;
      
      if (numsCount.values.any!"a % 2 != 0") {
        (-1).writeln;
        return;
      }

      bool isTandem(long[] arr) {
        if (arr.length % 2 > 0) return false;

        const h = arr.length / 2;
        return h.iota.all!(a => arr[a] == arr[a + h]);
      }

      long[][] isCreatable(long[] arr) {
        long[][] ops;
        int index;
        auto q = DList!long();
        foreach(a; arr) {
          if (q.empty) {
            q.insertFront(a);
            ops ~= [index, a];
          } else {
            if (a == q.front) {
              q.removeFront;
            } else {
              q.insertFront(a);
              ops ~= [index, a];
            }
          }
          index++;
        }

        return q.empty ? ops : [];
      }
      
      long ofs;
      int[] tandems;
      long[][] ops;
      int from;
      int i = -1;
      long value = -1;
      while(i < A.length.signed - 1) {
        const a = A[++i];

        if (value == -1) {
          value = a;
          from = i;
          continue;
        }

        if (a == value) {
          const to = i;
          tandems ~= (to - from) * 2;
          value = -1;
          if (A[from..to] == A[to..min($, to + to - from)]) continue;

          auto create = isCreatable(A[from + 1..to]);
          if (!create.empty) {
            foreach(c; create) ops ~= [c[0] + to + 1, c[1]];
            A.insertInPlace(to + 1, A[from + 1..to]);
            i += to - from - 1;
          } else {
            foreach(ic, c; A[from + 1..to]) ops ~= [ic + to + 1, c];
            A.insertInPlace(to + 1, A[from + 1..to]);
            A.insertInPlace(to + 1, A[from + 1..to].reverse.array);
            i += to - from - 1;
          }
        }
      }
      
      A.deb;

      ops.length.writeln;
      ops.each!(o => o.toAnswerString.writeln);
      tandems.length.writeln;
      tandems.toAnswerString.writeln;
    }

    foreach(i; 0..QN) {
      subSolve();
    }
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop;
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
T[] compress(T)(T[] arr, T origin = T.init) { T[T] indecies; arr.dup.sort.uniq.enumerate(origin).each!((i, t) => indecies[t] = i); return arr.map!(t => indecies[t]).array; }
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
struct ModInt(uint MD) if (MD < int.max) {ulong v;this(string v) {this(v.to!long);}this(int v) {this(long(v));}this(long v) {this.v = (v%MD+MD)%MD;}void opAssign(long t) {v = (t%MD+MD)%MD;}static auto normS(ulong x) {return (x<MD)?x:x-MD;}static auto make(ulong x) {ModInt m; m.v = x; return m;}auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r.v));}auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r.v));}auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r.v%MD).to!ulong);}auto opBinary(string op:"^^", T)(T r) const {long x=v;long y=1;while(r){if(r%2==1)y=(y*x)%MD;x=x^^2%MD;r/=2;} return make(y);}auto opBinary(string op:"/")(ModInt r) const {return this*memoize!inv(r);}static ModInt inv(ModInt x) {return x^^(MD-2);}string toString() const {return v.to!string;}auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}}
alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == float) || is(T == double) || is(T == real)) "%.16f".writefln(fn());
  else static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
  else static if (isInputRange!T) {
    static if (!is(string == ElementType!T) && isInputRange!(ElementType!T)) foreach(r; fn()) r.toAnswerString.writeln;
    else foreach(r; fn()) r.writeln;
  }
  else fn().writeln;
}
void runSolver() {
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
