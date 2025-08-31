void main() { runSolver(); }

void problem() {
  auto Q = scan!int;

  auto solve() {
    auto rbt = [0L].redBlackTree;

    foreach(_; 0..Q) {
      auto t = scan!int;
      if (t == 1) {
        auto x = scan!int;
        rbt,insert(x);
      } else {
        auto x = scan!int;
        auto y = scan!int;

        long[] ans;
        auto r = rbt.upperBound(x - 1);
        foreach(a; rbt.upperBound(x - 1)) {
          if (a > y) break;
          ans ~= a;
        }
      }
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

struct SkipList(T, int MAX_HEIGHT = 20) {
  class Node {
    T value;
    Node[] nexts;
    size_t[] skipped;
    bool sentinel = true;

    this() {}
    this(T v) {
      value = v;
      sentinel = false;
    }

    override string toString() {
      if (sentinel) {
        return (nexts.empty ? "$" : "^") ~ " %s".format(skipped);
      } else {
        return "%s : %s".format(value, skipped);
      }
    }

    bool tail() {
      return sentinel && skipped.empty;
    }
  }

  enum INF = int.max / 3;
  
  size_t length;
  Node head;
  auto rnd = Xorshift(1);

  this(T[] values) {
    rnd.seed(unpredictableSeed);
    this.length = values.length;
    this.head = new Node();

    Node[] preNodes = head.repeat(MAX_HEIGHT).array;
    size_t[] preIndex = new size_t[](MAX_HEIGHT);
    foreach(i, v; values.enumerate(1)) {
      auto node = new Node(v);
      foreach(h; 0..MAX_HEIGHT) {
        preNodes[h].nexts ~= node;
        preNodes[h].skipped ~= i - preIndex[h];
        preNodes[h] = node;
        preIndex[h] = i;
        if (!increaseHeight()) break;
      }
    }

    auto sentinel = new Node();
    foreach(h; 0..MAX_HEIGHT) {
      preNodes[h].nexts ~= sentinel;
      preNodes[h].skipped ~= 1;
    }
  }

  bool increaseHeight() {
    return uniform(0, 1.0, rnd) < 0.35;
  }

  void insert(size_t index, T value) {
    int height = 1;
    while(height < MAX_HEIGHT) {
      if (increaseHeight()) height++; else break;
    }

    auto newNode = new Node(value);
    newNode.nexts = new Node[](height);
    newNode.skipped = new size_t[](height);
    auto pres = preNodes(index);
    foreach(h, preNode, preIndex; lockstep(MAX_HEIGHT.iota, pres[0], pres[1])) {
      if (h < height) {
        // [[index, height], [h, preNode.value, preIndex]].deb;
        const preSkipped = preNode.skipped[h];
        newNode.skipped[h] = preSkipped - (index - preIndex);
        preNode.skipped[h] -= preSkipped - (index - preIndex) - 1;
        newNode.nexts[h] = preNode.nexts[h];
        preNode.nexts[h] = newNode;
      } else {
        preNode.skipped[h]++;
      }
    }
    // dbg();
  }

  T[] array() {
    T[] ret;
    for(auto cur = head; !cur.nexts.empty; cur = cur.nexts[0]) {
      if (cur.sentinel) continue;

      ret ~= cur.value;
    }
    return ret;
  }

  T get(size_t index) {
    auto step = index;
    auto cur = head;
    while(step > 0 && !cur.tail) {
      // cur.deb;
      auto h = nextFor(cur, step);
      step -= cur.skipped[h];
      cur = cur.nexts[h];
    }
    // cur.deb;

    if (step != 0) throw new Exception("invalid index"); else return cur.value;
  }

  Tuple!(Node[], size_t[]) preNodes(size_t index) {
    auto step = index;
    auto cur = head;

    auto ret = new Node[](MAX_HEIGHT);
    ret[] = head;
    auto indicies = new size_t[](MAX_HEIGHT);
    while(step > 0 && !cur.tail) {
      auto h = nextFor(cur, step);
      if (h == INF) break;

      // deb(h, " @ ", cur);
      step -= cur.skipped[h];
      indicies[0..h + 1] += cur.skipped[h];
      cur = cur.nexts[h];
      if (!cur.tail) ret[0..h + 1] = cur;
    }

    // deb("preNodes for ", index, ": ", step, indicies);
    if (step == 0 || index == 0) {
      return tuple(ret, indicies);
    } else {
      throw new Exception("invalid index");
    }
  }

  size_t nextFor(Node cur, size_t step) {
    if (step < 0) throw new Exception("invalid step");

    foreach_reverse(i, sk; cur.skipped) {
      if (sk <= step) return i;
    }
    return 0;
  }

  void dbg() {
    debug {
      "=============".deb;
      for(auto cur = head; !cur.nexts.empty; cur = cur.nexts[0]) {
        cur.deb;
      }
      "=============".deb;
    }
  }
}
