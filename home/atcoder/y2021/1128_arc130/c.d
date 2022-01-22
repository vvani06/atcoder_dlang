void main() { runSolver(); }

void problem() {
  auto A = scan;
  auto B = scan;

  auto solve() {
    bool ansReversed = B.length > A.length;
    if (ansReversed) swap(A, B);

    auto an = new long[](11);
    foreach(a; A) an[a - '0']++;
    auto bn = new long[](11);
    foreach(a; B) bn[a - '0']++;

    an.deb;
    bn.deb;

    char[] ansA = new char[](A.length);
    char[] ansB = new char[](B.length);
    int up;

    loops: foreach(i; 0..B.length) {
      void select(long a, long b) {
        if (an[a] == 0 || bn[b] == 0) assert(false, "item stocks is over");

        ansA[$ - 1 - i] = cast(char)('0' + a);
        ansB[$ - 1 - i] = cast(char)('0' + b);
        an[a]--;
        bn[b]--;
        // an.deb;
        up = (a + b + (up ? 1 : 0) >= 10);
      }

      spread: foreach(s; 0..10) {
        foreach(x; [5, 6, 4, 7, 3, 8, 2, 9, 1]) {
          if (x - up + s < 10 && an[x - up + s] > 0 && bn[10 - x] > 0) {
            select(x - up + s, 10 - x);
            continue loops;
          }
          if (10 - x + s < 10 && an[x - up] > 0 && bn[10 - x + s] > 0) {
            select(x - up, 10 - x + s);
            continue loops;
          }

          if (x + s < 10 && an[x + s] > 0 && bn[10 - x - up] > 0) {
            select(x + s, 10 - x - up);
            continue loops;
          }
          if (10 - x - up + s < 10 && an[x] > 0 && bn[10 - x - up + s] > 0) {
            select(x, 10 - x - up + s);
            continue loops;
          }

          if (x - up + s < 10 && bn[x - up + s] > 0 && an[10 - x] > 0) {
            select(10 - x, x - up + s);
            continue loops;
          }
          if (10 - x + s < 10 && bn[x - up] > 0 && an[10 - x + s] > 0) {
            select(10 - x + s, x - up);
            continue loops;
          }

          if (x + s < 10 && bn[x + s] > 0 && an[10 - x - up] > 0) {
            select(10 - x - up, x + s);
            continue loops;
          }
          if (10 - x - up + s < 10 && bn[x] > 0 && an[10 - x - up + s] > 0) {
            select(10 - x - up + s, x);
            continue loops;
          }
        }
      }
      spread2: foreach_reverse(s; 0..10) {
        foreach(x; [5, 6, 4, 7, 3, 8, 2, 9, 1]) {
          if (x - up - s > 0 && an[x - up - s] > 0 && bn[10 - x] > 0) {
            select(x - up - s, 10 - x);
            continue loops;
          }
          if (10 - x - s > 0 && an[x - up] > 0 && bn[10 - x - s] > 0) {
            select(x - up, 10 - x - s);
            continue loops;
          }

          if (x - s > 0 && an[x - s] > 0 && bn[10 - x - up] > 0) {
            select(x - s, 10 - x - up);
            continue loops;
          }
          if (10 - x - up - s > 0 && an[x] > 0 && bn[10 - x - up - s] > 0) {
            select(x, 10 - x - up - s);
            continue loops;
          }

          if (x - up - s > 0 && bn[x - up - s] > 0 && an[10 - x] > 0) {
            select(10 - x, x - up - s);
            continue loops;
          }
          if (10 - x - s > 0 && bn[x - up] > 0 && an[10 - x - s] > 0) {
            select(10 - x - s, x - up);
            continue loops;
          }

          if (x - s > 0 && bn[x - s] > 0 && an[10 - x - up] > 0) {
            select(10 - x - up, x - s);
            continue loops;
          }
          if (10 - x - up - s > 0 && bn[x] > 0 && an[10 - x - up - s] > 0) {
            select(10 - x - up - s, x);
            continue loops;
          }
        }
      }
    }

    foreach(i; B.length..A.length) {
      foreach_reverse(x; 1..10) {
        if (an[x] == 0) continue;

        ansA[$ - 1 - i] = cast(char)('0' + x);
        an[x]--;
        break;
      }
    }

    if (ansReversed) swap(ansA, ansB);
    ansA.writeln;
    ansB.writeln;
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
