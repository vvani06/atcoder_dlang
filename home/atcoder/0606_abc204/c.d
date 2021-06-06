void main() { runSolver(); }

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto PATH = scan!long(M * 2).chunks(2);

  auto solve() {
    if (M == 0) return N;

    auto pathes = new long[][](N, 0);
    foreach(p; PATH) pathes[p[0] - 1] ~= p[1] - 1;

    long[long] memo;
    long search(long from, long origin) {
      if (from in memo) return memo[from];

      long sum = 1;
      foreach(p; pathes[from]) if (origin != p)sum += search(p, origin);
      return memo[from] = sum;
    }

    long ans;
    foreach(from; 0..N) {
      bool[long] visited;
      for(auto q = new DList!long([from]); !q.empty; ) {
        auto p = q.front; q.removeFront;
        if (p in visited) continue;

        visited[p] = true;
        ans++;
        foreach(n; pathes[p]) {
          if (n in visited) continue;
          q.insert(n);
        }
      }
    }

    return ans;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time;
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
  debug { BORDER.writeln; while(true) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct Set(T) {
  private bool[T] v;
  this(T t) { v[t] = true; }
  this(InputRange!T r) { foreach(t; r) v[t] = true; }
  
  size_t length() { return v.length; }
  bool has(T t) { return !!(t in v); }
  auto opIndex() { return v.keys; }

  bool add(T t) { if (t in v) return false; else return v[t] = true; }
  void add(InputRange!T r) { foreach(t; r) add(t); }
  void add(Set!T s) { foreach(t; s[]) add(t); }
  bool remove(T t) { if (!(t in v)) return false; else { v.remove(t); return true; }}
  void remove(InputRange!T r) { foreach(t; r) remove(t); }
  void remove(Set!T s) { foreach(t; s[]) remove(t); }
}

