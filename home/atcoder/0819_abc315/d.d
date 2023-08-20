void main() { runSolver(); }

void problem() {
  auto H = scan!int;
  auto W = scan!int;
  auto S = scan!string(H).map!(s => s.map!(c => c - 'a').array).array;

  auto solve() {
    auto charDistributionsByRow = new int[][](H, 26);
    auto charDistributionsByColumn = new int[][](W, 26);
    foreach(r; 0..H) foreach(c; 0..W) {
      auto ch = S[r][c];
      charDistributionsByRow[r][ch]++;
      charDistributionsByColumn[c][ch]++;
    }

    auto charKindsByRow = charDistributionsByRow.map!(d => d.count!"a > 0").array;
    auto charKindsByColumn = charDistributionsByColumn.map!(d => d.count!"a > 0").array;
    auto rows = H;
    auto columns = W;

    auto deletedRow = new bool[](H);
    auto deletedColumn = new bool[](W);

    auto row = H.iota.array;
    auto column = W.iota.array;
    while(true) {
      int[] rowsToDelete;
      row = row.filter!(r => !deletedRow[r]).array;
      foreach(r; row) {
        if (charKindsByRow[r] == 1 && columns > 1) {
          rowsToDelete ~= r;
        }
      }

      int[] columnsToDelete;
      column = column.filter!(r => !deletedColumn[r]).array;
      foreach(c; W.iota.filter!(c => !deletedColumn[c])) {
        auto chars = charDistributionsByColumn[c].filter!"a > 0".array;
        if (charKindsByColumn[c] == 1 && rows > 1) {
           columnsToDelete ~= c;
        }
      }

      foreach(r; rowsToDelete) {
        foreach(c; 0..W) {
          if (deletedColumn[c]) continue;

          if (--charDistributionsByRow[r][S[r][c]] == 0) charKindsByRow[r]--;
          if (--charDistributionsByColumn[c][S[r][c]] == 0) charKindsByColumn[c]--;
        }
        deletedRow[r] = true;
        rows--;
      }
      foreach(c; columnsToDelete) {
        foreach(r; 0..H) {
          if (deletedRow[r]) continue;

          if (--charDistributionsByRow[r][S[r][c]] == 0) charKindsByRow[r]--;
          if (--charDistributionsByColumn[c][S[r][c]] == 0) charKindsByColumn[c]--;
        }
        deletedColumn[c] = true;
        columns--;
      }

      if (rowsToDelete.empty && columnsToDelete.empty) break;
    }

    return charDistributionsByRow.map!"a.sum".sum;
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
void deb(T ...)(T t){ debug asAnswer(t).writeln; }
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
