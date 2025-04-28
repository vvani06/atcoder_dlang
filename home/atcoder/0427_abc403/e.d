void main() { runSolver(); }

void problem() {
  auto Q = scan!int;

  auto xTrie = new TrieTree!char();
  auto yTrie = new TrieTree!char();

  auto solve() {
    int ans;
    foreach(_; 0..Q) {
      auto t = scan!int;
      auto s = scan;
      auto l = s.length.to!int;

      if (t == 1) {
        auto removee = yTrie.remove(s);
        if (removee) ans -= removee.count;
        xTrie.insert(s);
      } else {
        auto nodes = xTrie.search(s);
        if (!nodes.any!"a.last") {
          ans++;
          yTrie.insert(s);
        }
      }

      writeln(ans);
    }

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
void runSolver() {
  static import std.datetime.stopwatch;
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

class TrieTree(T) {
  class Node {
    T value;
    int count;
    Node[T] children;
    Node parent;
    bool last;

    this(T c, Node p) {
      value = c;
      parent = p;
    }

    Node next(T c) {
      return children.get(c, null);
    }

    void insert(T c) {
      children[c] = new Node(c, this);
    }

    void remove(T c) {
      children.remove(c);
    }

    override string toString() {
      return "TrieNode: %s (%s) [%(%s %)]".format(value, count, children.keys);
    }
  }

  Node root;
  this() {
    root = new Node(0, null);
  }

  Node[] search(S)(S s) {
    Node[] ret;

    Node cur = root;
    foreach(c; s) {
      cur = cur.next(c);

      if (cur is null) break; else ret ~= cur;
    }
    return ret;
  }

  Node remove(S)(S s) {
    Node cur = root;
    foreach(i, c; s) {
      if (i == s.length - 1 && cur.next(c)) {
        auto target = cur.next(c);
        cur.remove(c);
        while(cur !is null) {
          cur.count -= target.count;
          cur = cur.parent;
        }
        return target;
      }

      if ((cur = cur.next(c)) is null) break;
    }
    return null;
  }

  Node insert(S)(S s) {
    Node cur = root;
    foreach(c; s) {
      if (cur.next(c) is null) {
        cur.insert(c);
      }

      cur = cur.next(c);
      cur.count++;
    }

    cur.last = true;
    return cur;
  }
}