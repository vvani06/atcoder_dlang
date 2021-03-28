void main() {
  problem();
}

void problem() {
  auto H = scan!long;
  auto W = scan!long;
  auto K = scan!long;
  auto MARKS = K.iota.map!(_ => Mark(scan!long - 1, scan!long - 1, scan!char)).array;

  void solve() {
    char[][] field;
    foreach(h; 0..H) {
      field ~= new char[W];
      field[$-1][] = ' ';
    }
    foreach(m; MARKS) {
      field[m.y][m.x] = m.mark;
    }

    alias GridMint = GridValue!MInt9;
    const ZP = GridPoint.ZERO;
    const GP = GridPoint(W-1, H-1);
    auto dp = GridMint(W, H, MInt9(0));
    dp[ZP] = MInt9(3) ^^ (W*H - K);
    const mul2Div3 = MInt9(2) / MInt9(3);

    void calcDpAt(GridPoint p) {
      if (p == ZP) return;

      if (p.x > 0) {
        const left = p.left;
        if (left.of(field) != 'D') {
          auto add = dp[left];
          if (left.of(field) == ' ') add = add * mul2Div3;
          dp[p] = dp[p] + add;
        }
      }

      if (p.y > 0) {
        const up = p.up;
        if (up.of(field) != 'R') {
          auto add = dp[up];
          if (up.of(field) == ' ') add = add * mul2Div3;
          dp[p] = dp[p] + add;
        }
      }
    }

    foreach(u; 0..min(H, W)) {
      foreach(y; u..H) calcDpAt(GridPoint(u, y));
      foreach(x; u+1..W) calcDpAt(GridPoint(x, u));
    }

    dp.deb;
    dp[GP].writeln;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
alias Mark = Tuple!(long, "y", long, "x", char, "mark");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------

struct GridPoint {
  static enum ZERO = GridPoint(0, 0);
  long x, y;
  this(long x, long y) {
    this.x = x;
    this.y = y;
  }

  inout GridPoint left() { return GridPoint(x - 1, y); }
  inout GridPoint right() { return GridPoint(x + 1, y); }
  inout GridPoint up() { return GridPoint(x, y - 1); }
  inout GridPoint down() { return GridPoint(x, y + 1); }
  inout GridPoint leftUp() { return GridPoint(x - 1, y - 1); }
  inout GridPoint leftDown() { return GridPoint(x - 1, y + 1); }
  inout GridPoint rightUp() { return GridPoint(x + 1, y - 1); }
  inout GridPoint rightDown() { return GridPoint(x + 1, y + 1); }
  inout T of(T)(inout ref T[][] grid) { return grid[y][x]; }
}

struct GridValue(T) {
  T nullValue;
  GridPoint size;
  T[][] g;

  this(GridPoint p, T nullValue) {
    size = p;
    foreach(y; 0..size.y) g ~= new T[size.x];
    this.nullValue = nullValue;
  }

  this(long width, long height, T nullValue) {
    this(GridPoint(width, height), nullValue);
  }

  bool contains(GridPoint p) { return (0 <= p.y && p.y < size.y && 0 <= p.x && p.x < size.x); }
  T at(GridPoint p) { return contains(p) ? g[p.y][p.x] : nullValue; }
  T opIndex(GridPoint p) { return at(p); }
  T setAt(GridPoint p, T value) { return contains(p) ? g[p.y][p.x] = value : nullValue; }
  T opIndexAssign(T value, GridPoint p) { return setAt(p, value); }
}

struct ModInt(uint MD) if (MD < int.max) {
  ulong v;
  this(int v) {this(long(v));}
  this(long v) {this.v = (v%MD+MD)%MD;}
  void opAssign(long v) { this.v = (v%MD+MD)%MD; }
  static auto normS(ulong x) {return (x<MD)?x:x-MD;}
  static auto make(ulong x) {ModInt m; m.v = x; return m;}
  auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r.v));}
  auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r.v));}
  auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r.v%MD).to!ulong);}
  auto opBinary(string op:"^^", T)(T r) const {long x=v;long y=1;while(r){if(r%2==1)y=(y*x)%MD;x=x^^2%MD;r/=2;} return make(y);}
  auto opBinary(string op:"/")(ModInt r) const {return this*inv(r);}
  string toString() const {return v.to!string;}
  auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}

  static typeof(this) inv(ModInt x) {if(x in memoInv) return memoInv[x]; else return memoInv[x] = x^^(MD-2);}
  static typeof(this)[typeof(this)] memoInv;
}

alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);
