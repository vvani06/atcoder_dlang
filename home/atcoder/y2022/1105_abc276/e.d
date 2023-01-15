void main() { runSolver(); }

void problem() {
  auto H = scan!int;
  auto W = scan!int;
  auto G = scan!string(H);
  
  auto solve() {
    int SX, SY;
    foreach(y; 0..H) foreach(x; 0..W) {
      if (G[y][x] == 'S') {
        SX = x;
        SY = y;
        break;
      }
    }

    struct Coord {
      int x, y;
      int id() { return W*y + x; }
    }

    enum dirs = zip([1, 0, -1, 0], [0, 1, 0, -1]).array;
    Coord[] goals;
    foreach(d; dirs) {
      auto dx = SX + d[0];
      auto dy = SY + d[1];
      if (min(dx, dy) < 0 || dx >= W || dy >= H || G[dy][dx] != '.') continue;

      goals ~= Coord(dx, dy);
    }
    
    foreach(gi, start; goals) {
      bool[][] visited = new bool[][](H, W);
      bool[][] queued = new bool[][](H, W);
      visited[SY][SX] = true;

      for(auto queue = DList!Coord(start); !queue.empty;) {
        auto c = queue.front;
        queue.removeFront;
        if (visited[c.y][c.x]) continue;
        visited[c.y][c.x] = true;

        foreach(g; goals) {
          if (g != start && c == g) {
            // [start, g].deb;
            return YESNO[true];
          }
        }

        foreach(d; dirs) {
          auto dx = c.x + d[0];
          auto dy = c.y + d[1];
          if (min(dx, dy) < 0 || dx >= W || dy >= H || G[dy][dx] != '.') continue;

          if (!visited[dy][dx] && !queued[dy][dx]) {
            // [c, Coord(dx, dy)].deb;
            queue.insertBack(Coord(dx, dy));
            queued[dy][dx] = true;
          }
        }
      }
    }

    return YESNO[false];
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
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
