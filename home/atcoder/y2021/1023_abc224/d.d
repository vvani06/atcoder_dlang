void main() { runSolver(); }

void problem() {
  auto M = scan!long;
  auto E = scan!long(M * 2).chunks(2).array;
  auto P = scan!long(8);
 
  auto solve() {
    auto graph = new long[][](9, 0);
    foreach(e; E) {
      e[0]--; e[1]--;
      graph[e[0]] ~= e[1];
      graph[e[1]] ~= e[0];
    }

    auto initState = new char[](9);
    initState[] = '0';
    foreach(i, p; P) {
      initState[p - 1] = cast(char)(i + 1 + '0');
    }
    initState.deb;
    long[string] cache;

    enum string GOAL = "123456780";
    alias HV = Tuple!(string, "state", long, "count");
    for(auto q = heapify!"a.count > b.count"([HV(initState.to!string, 0)]); !q.empty;) {
      auto p = q.front;
      q.removeFront;
      if (p.state == GOAL) return p.count;
      if (p.state in cache && p.count >= cache[p.state]) continue;

      cache[p.state] = p.count;
      const newCount = p.count + 1;
      foreach(e; E) {
        if (p.state[e[0]] != '0' && p.state[e[1]] != '0') continue;
        
        char[] moved = p.state.dup;
        swap(moved[e[0]], moved[e[1]]);
        string newState = moved.idup;

        if (!(newState in cache) || cache[newState] > newCount) {
          q.insert(HV(newState, newCount));
        }
      }
    }

    return -1;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop;
struct CombinationRange(T) { private { int combinationSize; int elementSize; int pointer; int[] cursor; T[] elements; T[] current; } public: this(T[] t, int combinationSize) { this.combinationSize = combinationSize; this.elementSize = cast(int)t.length; pointer = combinationSize - 1; cursor = new int[combinationSize]; current = new T[combinationSize]; elements = t.dup; foreach(i; 0..combinationSize) { cursor[i] = i; current[i] = elements[i]; } } @property T[] front() { return current; } void popFront() { if (pointer == -1) return; if (cursor[pointer] == elementSize + pointer - combinationSize) { pointer--; popFront(); if (pointer < 0) return; pointer++; cursor[pointer] = cursor[pointer - 1]; current[pointer] = elements[cursor[pointer]]; } cursor[pointer]++; current[pointer] = elements[cursor[pointer]]; } bool empty() { return pointer == -1; } }
CombinationRange!T combinations(T)(T[] t, int size) { return CombinationRange!T(t, size); }
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

struct Graph {
  long size;
  long[][] g;
  this(long size) {
    this.size = size;
    g = new long[][](size, 0);
  }

  Graph addUnidirectionalEdge(long[] edge) {
    g[edge[0]] ~= edge[1];
    return this;
  }

  Graph addUnidirectionalEdges(long[][] edges) {
    edges.each!(e => addUnidirectionalEdge(e));
    return this;
  }

  Graph addBidirectionalEdge(long[] edge) {
    g[edge[0]] ~= edge[1];
    g[edge[1]] ~= edge[0];
    return this;
  }

  Graph addBidirectionalEdges(long[][] edges) {
    edges.each!(e => addBidirectionalEdge(e));
    return this;
  }

  alias tourCallBack = void delegate(long);
  void tour(long start, tourCallBack funcIn, tourCallBack funcOut) {
    void dfs(long cur, long pre) {
      if (funcIn) funcIn(cur);
      foreach(n; g[cur]) {
        if (n != pre) dfs(n, cur);
      }
      if (funcOut) funcOut(cur);
    }
    dfs(start, -1);
  }

  long[] topologicalSort() {
    auto depth = new long[](size);
    foreach(e; g) foreach(p; e) depth[p]++;

    auto q = heapify!"a > b"(new long[](0));
    foreach(i; 0..size) if (depth[i] == 0) q.insert(i);

    long[] sorted;
    while(!q.empty) {
      auto p = q.front;
      q.removeFront;
      foreach(n; g[p]) {
        depth[n]--;
        if (depth[n] == 0) q.insert(n);
      }

      sorted ~= p;
    }

    return sorted;
  }
}
