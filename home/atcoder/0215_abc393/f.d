void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto P = scan!int(N);

  auto solve() {
    auto skipList = SkipList!(int, 20)([]);
    foreach(n, i; lockstep(iota(1, N + 1), P)) skipList.insert(i - 1, n);
    
    return skipList.array();
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

struct SegTree(alias pred = "a + b", T = long) {
  alias predFun = binaryFun!pred;
  int size;
  T[] data;
  T monoid;
 
  this(T[] src, T monoid = T.init) {
    this.monoid = monoid;

    for(int i = 2; i < 2L^^32; i *= 2) {
      if (src.length <= i) {
        size = i;
        break;
      }
    }
    
    data = new T[](size * 2);
    foreach(i, s; src) data[i + size] = s;
    foreach_reverse(b; 1..size) {
      data[b] = predFun(data[b * 2], data[b * 2 + 1]);
    }
  }
 
  void update(int index, T value) {
    int i = index + size;
    data[i] = value;
    while(i > 0) {
      i /= 2;
      data[i] = predFun(data[i * 2], data[i * 2 + 1]);
    }
  }

  void add(int index, T value) {
    update(index, get(index) + value);
  }
 
  T get(int index) {
    return data[index + size];
  }
 
  T sum(int a, int b, int k = 1, int l = 0, int r = -1) {
    if (r < 0) r = size;
    
    if (r <= a || b <= l) return monoid;
    if (a <= l && r <= b) return data[k];
 
    T leftValue = sum(a, b, 2*k, l, (l + r) / 2);
    T rightValue = sum(a, b, 2*k + 1, (l + r) / 2, r);
    return predFun(leftValue, rightValue);
  }

  T[] array() {
    return size.iota.map!(i => get(i)).array;
  }

  int lowerBound(T border) {
    return binarySearch((int t) => sum(0, t) < border, 0, size + 1);
  }

  int upperBound(T border) {
    return binarySearch((int t) => sum(t, size) < border, size, -1);
  }

  private K binarySearch(K)(bool delegate(K) cond, K l, K r) { return binarySearch((K k) => k, cond, l, r); }
  private T binarySearch(T, K)(K delegate(T) fn, bool delegate(K) cond, T l, T r) {
    auto ok = l;
    auto ng = r;
    const T TWO = 2;
  
    bool again() {
      static if (is(T == float) || is(T == double) || is(T == real)) {
        return !ng.approxEqual(ok, 1e-08, 1e-08);
      } else {
        return abs(ng - ok) > 1;
      }
    }
  
    while(again()) {
      const half = (ng + ok) / TWO;
      const halfValue = fn(half);
  
      if (cond(halfValue)) {
        ok = half;
      } else {
        ng = half;
      }
    }
  
    return ok;
  }
}
