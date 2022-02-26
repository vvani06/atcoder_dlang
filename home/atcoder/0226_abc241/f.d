void main() { runSolver(); }

void problem() {
  auto H = scan!long;
  auto W = scan!long;
  auto N = scan!int;
  auto S = Point(scan!long, scan!long);
  auto G = Point(scan!long, scan!long);
  auto B = N.iota.map!(_ => Point(scan!long, scan!long)).array;

  auto solve() {
    RedBlackTree!(Point, "a.y < b.y")[long] perX;
    RedBlackTree!(Point, "a.x < b.x")[long] perY;
    foreach(b; B) {
      if (!(b.x in perX)) perX[b.x] = (new Point[](0)).redBlackTree!"a.y < b.y";
      perX[b.x].insert(b);
      if (!(b.y in perY)) perY[b.y] = (new Point[](0)).redBlackTree!"a.x < b.x";
      perY[b.y].insert(b);
    }

    bool[Point] visited;
    long ans;
    for(auto q = new DList!Point(S); !q.empty;) {
      bool[Point] qq;
      ans++;
      while(!q.empty) {
        auto p = q.front; q.removeFront;
        visited[p] = true;

        if (p.y in perY) {
          auto lefts = perY[p.y].lowerBound(Point(p.x - 1, p.y));
          if (!lefts.empty) {
            auto b = lefts.back;
            auto n = Point(b.x + 1, b.y);
            if (!(n in visited)) qq[n] = true;
          }

          auto rights = perY[p.y].upperBound(Point(p.x + 1, p.y));
          if (!rights.empty) {
            auto b = rights.front;
            auto n = Point(b.x - 1, b.y);
            if (!(n in visited)) qq[n] = true;
          }
        }

        if (p.x in perX) {
          auto lefts = perX[p.x].lowerBound(Point(p.x, p.y - 1));
          if (!lefts.empty) {
            auto b = lefts.back;
            auto n = Point(b.x, b.y + 1);
            if (!(n in visited)) qq[n] = true;
          }

          auto rights = perX[p.x].upperBound(Point(p.x, p.y + 1));
          if (!rights.empty) {
            auto b = rights.front;
            auto n = Point(b.x, b.y - 1);
            if (!(n in visited)) qq[n] = true;
          }
        }
      }

      if (G in qq) return ans;
      q.insert(qq.keys);
    }

    return -1;
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
