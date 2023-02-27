void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto S = scan!string(N);

  auto solve() {
    auto visited = new bool[](N);
    auto queued = new bool[](N);
    auto queue = DList!int(0);
    auto ans = new int[](N);
    auto froms = new int[][](N, 0);
    froms[0] ~= 0;

    int steps;
    while(!queue.empty) {
      auto qi = queue.array;
      queue.clear;
      foreach(p; qi) {
        if (visited[p]) continue;
        visited[p] = true;
        ans[p] = steps;

        foreach(i, c; S[p].enumerate(1)) {
          if (c == '0') continue;
          const t = p + i;
          froms[t] ~= p;
          if (queued[t]) continue;

          queued[t] = true;
          queue.insertBack(t);
        }
      }
      steps++;
    }

    ans.deb;
    froms.deb;

    auto tos = new int[][](N);
    foreach (i; 0..N) {
      if (!froms[i].empty) tos[froms[i][0]] ~= i;
    }

    froms.deb;
    tos.deb;

    foreach (k; 1..N - 1) {
      int ansK = ans[$ - 1];
      int eff = 10000000;
      if (tos[k].empty) {
        eff = 0;
      } else {
        foreach(to; tos[k]) {
          foreach(f; froms[to][0..min($, 10)]) {
            if (f == k) continue;
            eff.chmin(ans[k] - ans[f]);
          }
        }
      }

      max(-1, ansK - eff).writeln;
    }
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std, core.bitop;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
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
  static import std.datetime.stopwatch;
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
