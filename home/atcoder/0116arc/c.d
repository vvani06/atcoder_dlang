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

    MInt9[] toK = [ ' ': 2, 'X': 1, 'R': 1, 'D': 1 ];
    field.deb;

    alias GridMint = GridValue!MInt9;
    const ZP = GridPoint.ZERO;
    const GP = GridPoint(W-1, H-1);

    auto dp = GridMint(W, H, MInt9(0));
    dp[GP] = GP.of(field) == ' ' ? MInt9(3) : MInt9(1);

    MInt9[] pows = new MInt9[max(W, H)];
    pows[0] = MInt9(1);
    foreach(i; 1..(max(W, H))) pows[i] = pows[i-1] * MInt9(3);

    foreach(i; 1..W+H-1) {
      auto base = GridPoint(W - i - 1, H - 1);
      if (base.x < 0) {
        base.y = H - 1 + base.x;
        base.x = 0;
      }
      const times = min(W - base.x, H);
      auto bb = base;

      long whites = 0;
      foreach(j; 0..times) {
        if (base.of(field) == ' ') whites = whites + 1;
        base.x++;
        base.y--;
        if (base.y == -1) break;
      }

      void calcDpAt(GridPoint p) {
        p.deb;

        const pf = p.of(field);
        const right = p.right;
        if (right.x < W && pf != 'D') {
          MInt9 add = dp[right] * toK[pf];
          add = add * pows[pf == ' ' ? whites - 1 : whites];
          dp[p] = dp[p] + add;
        }

        const down = p.down;
        if (down.y < H && pf != 'R') {
          MInt9 add = dp[down] * toK[pf];
          add = add * pows[pf == ' ' ? whites - 1 : whites];
          dp[p] = dp[p] + add;
        }
      }
      
      base = bb;
      foreach(j; 0..times) {
        calcDpAt(base);
        base.x++;
        base.y--;
        if (base.y == -1) break;
      }
    }

    dp.deb;
    dp[ZP].writeln;
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
  static ModInt inv(ModInt x) {return x^^(MD-2);};
  string toString() const {return v.to!string;}
  auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}
}

alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);
