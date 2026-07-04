void main() { runSolver(); }

void problem() {
  auto N = scan!long;
  auto K = scan!int;
  auto S = scan!string(K);

  auto solve() {
    auto trie = new Trie!dchar();
    foreach(s; S) trie.insert(s.array);

    auto size = trie.nodes.length.to!int;
    auto memo = new MInt9[](size);
    memo[0] = MInt9(1);

    trie.nodes.map!(n => n.children).each!deb;

    foreach(_; 0..min(1000, N)) {
      auto pre = new MInt9[](size);
      swap(memo, pre);

      foreach(c; 0..26) {
        auto dc = c + 'a';

        foreach(i; 0..size) {
          auto from = trie.nodes[i];
          auto next = from.children.get(dc, from).id;
          memo[next] += pre[i];
        }
      }
    }

    MInt9 ans;
    foreach(i; 0..size) {
      if (trie.nodes[i].end) {
        memo[i].deb;
      } else {
        ans += memo[i];
      }
    }
    return ans;
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
void deb(T ...)(T t){ debug t.writeln; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
  else asAnswer(fn()).writeln;
}
void runSolver(bool multiCase = false) {
  static import std.datetime.stopwatch;
  debug { if (multiCase) writeln("! Run as multi-case"); }
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(multiCase ? scan!int : 1)); BORDER.writeln; } }
  else foreach(_; 0..multiCase ? scan!int : 1) problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}

class Trie(T) {
  class Node {
    int id;
    Node[T] children;
    bool end;
  }

  Node root;
  Node[] nodes;

  this() {
    root = new Node();
    nodes ~= root;
  }

  void insert(T[] s) {
    auto node = root;

    foreach(t; s) {
      if (!(t in node.children)) {
        auto n = new Node();
        n.id = nodes.length.to!int;
        nodes ~= n;
        node.children[t] = n;
      }
      node = node.children[t];
    }
    node.end = true;
  }
}