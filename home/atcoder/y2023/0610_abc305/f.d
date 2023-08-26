void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;

  auto solve() {
    auto graph = new int[][](N + 1, 0).map!redBlackTree.array;

    int[] search(int from) {
      DList!int route;
      auto visited = new bool[](N + 1);

      bool dfs(int cur, int pre) {
        visited[cur] = true;
        route.insertBack(cur);
        if (cur == N) return true;
        
        foreach(n; graph[cur]) {
          if (visited[n]) continue;
          
          if (dfs(n, cur)) return true;
        }

        route.removeBack;
        return false;
      }
      dfs(from, from);
      return route.array;
    }

    int cur = 1;
    auto visited = new bool[](N + 1);

    void moveTo(int to) {
      to.writeln;
      stdout.flush;
      cur = to;
    }

    int[] routeToGoal;
    DList!int past;
    foreach(_; 0..N * 2) {
      visited[cur] = true;
      past.insertBack(cur);
      auto line = scan;
      if (line == "OK") break;
      if (line == "-1") break;

      auto neighbors = scan!int(line.to!int);
      foreach(n; neighbors) {
        graph[cur].insert(n);
        graph[n].insert(cur);
      }

      auto route = search(cur);
      if (!route.empty) {
        routeToGoal = route;
        break;
      }
      
      bool moved;
      foreach(n; graph[cur]) {
        if (!visited[n]) {
          moveTo(n);
          moved = true;
          break;
        }
      }

      if (!moved) {
        past.removeBack;
        auto b = past.back;
        past.removeBack;
        moveTo(b);
        continue;
      }
    }

    foreach(r; routeToGoal[1..$]) {
      moveTo(r);
      auto line = readln.chomp;

      if (line == "OK") break;
      if (line == "-1") break;
    }
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
