void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int[] A = scan!int(N ^^ 2);
  int MAX = N ^^ 2 / 2;

  class Pair {
    int num;
    Pair child, next;
    Pair parent, pre;

    this(int num) {
      this.num = num;
    }

    Pair setChild(Pair p) {
      child = p;
      p.parent = this;
      return this;
    }

    Pair setNext(Pair p) {
      next = p;
      p.pre = this;
      return this;
    }

    Pair removeChild() {
      deb("removeChild:", this.num);
      // auto childChild = child.child;
      // if (childChild) childChild.parent = this;

      child.parent = null;
      auto p = child;
      child = null;
      return p;
    }

    Pair removeNext() {
      deb("removeNext:", this.num);
      // auto nextNext = next.next;
      // if (nextNext) nextNext.pre = this;

      next.pre = null;
      auto p = next;
      // next = nextNext;
      next = null;
      return p;
    }

    bool isFree() {
      return child is null || next is null;
    }

    override string toString() {
      return "Pairs(%s [%s]) => %s".format(num, child, next);
    }
  }

  class Pairs {
    Pair root;
    Pair[] all;

    this() {
      root = new Pair(-1);
      all = new Pair[](MAX);

      auto usable = new int[](0).redBlackTree;

      foreach(n; iota(MAX).array.randomShuffle(RND)) {
        all[n] = new Pair(n);

        if (usable.empty) {
          root.setChild(all[n]);
        } else {
          auto nodeNum = usable.array.choice(RND);
          auto node = all[nodeNum];

          if (node.child is null) {
            node.setChild(all[n]);
          } else {
            node.setNext(all[n]);
          }

          if (!node.isFree) usable.removeKey(nodeNum);
        }

        usable.insert(n);
      }
    }

    this(Pairs ps) {
      root = new Pair(-1);
      all = new Pair[](MAX);

      void dfs(Pair cur) {
        if (cur.child) {
          all[cur.child.num] = new Pair(cur.child.num);
          all[cur.num].setChild(all[cur.child.num]);
          dfs(cur.child);
        }

        if (cur.next) {
          all[cur.next.num] = new Pair(cur.next.num);
          all[cur.num].setNext(all[cur.next.num]);
          dfs(cur.next);
        }
      }

      all[ps.root.child.num] = new Pair(ps.root.child.num);
      root.setChild(all[ps.root.child.num]);
      dfs(ps.root.child);
    }

    Pair choiceFree() {
      auto candidates = array.sort.uniq.array;
      foreach(i; candidates.randomShuffle(RND)) {
        if (all[i].isFree) return all[i];
      }
      assert(false, "no candidates");
    }

    Pair choiceLeaf() {
      foreach(i; iota(MAX).array.randomShuffle(RND)) {
        if (all[i].child is null && all[i].next is null) return all[i];
      }
      assert(false, "no candidates");
    }

    Pair choiceAll() {
      return all[uniform(0, MAX, RND)];
    }

    int[] array() {
      int[] ret;
      void dfs(Pair cur) {
        ret ~= cur.num;
        if (cur.child) dfs(cur.child);

        ret ~= cur.num;
        if (cur.next) dfs(cur.next);
      }
      dfs(root.child);
      return ret;
    }
  }

  auto pairs = new Pairs();

  int[] rs = new int[](N^^2);
  int[] cs = new int[](N^^2);
  {
    int[] ofs = new int[](MAX);
    foreach(r; 0..N) foreach(c; 0..N) {
      auto num = A[r * N + c];
      rs[num + ofs[num]] = r;
      cs[num + ofs[num]] = c;
      ofs[num] = MAX;
    }
  }

  struct Sim {
    int moves;
    string[] ans;

    this(int[] pairs) {
      int r, c;
      bool[] used = new bool[](N^^2);
      foreach(num; pairs.array) {
        int target;
        int bestDist = N^^2;
        foreach(t; [num, num + MAX]) {
          if (used[t]) continue;

          if (bestDist.chmin(abs(r - rs[t]) + abs(c - cs[t]))) {
            target = t;
          }
        }

        used[target] = true;
        // [target, bestDist].deb;
        moves += bestDist;
        while(r < rs[target]) {
          r++;
          ans ~= "D";
        }
        while(r > rs[target]) {
          r--;
          ans ~= "U";
        }
        while(c < cs[target]) {
          c++;
          ans ~= "R";
        }
        while(c > cs[target]) {
          c--;
          ans ~= "L";
        }
        ans ~= "Z";
      }
    }

    string asAns() {
      return ans.joiner(" ").to!string;
    }
  }

  Pairs bestPairs = new Pairs(pairs);
  Sim bestSim = Sim(bestPairs.array);

  bestPairs.array.deb;
  
  // foreach(_; 0..100) {
  int tried;
  while(!elapsed(1900)) {
    tried++;
    Pair swappee = pairs.choiceAll();
    if (swappee == pairs.root.child) continue;

    if (swappee.pre) {
      swappee.pre.removeNext();
    } else {
      swappee.parent.removeChild();
    }

    Pair swapTo = pairs.choiceFree();
    if (swapTo.next is null) {
      swapTo.setNext(swappee);
    } else {
      swapTo.setChild(swappee);
    }

    auto sim = Sim(pairs.array);
    if (bestSim.moves > sim.moves) {
      bestSim = sim;
      bestPairs = new Pairs(pairs);
      sim.moves.deb;
      tried = 0;
    } else if (tried > 0) {
      pairs = new Pairs(bestPairs);
      tried = 0;
    }
  }

  writeln(bestSim.asAns());
}

// ----------------------------------------------

import std;
import core.bitop;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(lazy T t){ debug { write("# "); writeln(t); }}
void debf(T ...)(lazy T t){ debug { write("# "); writefln(t); }}
// void deb(T ...)(T t){ debug {  }}
T[] divisors(T)(T n) { T[] ret; for (T i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == float) || is(T == double) || is(T == float)) "%.16f".writefln(fn());
  else static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
  else static if (isInputRange!T) {
    static if (!is(string == ElementType!T) && isInputRange!(ElementType!T)) foreach(r; fn()) r.toAnswerString.writeln;
    else foreach(r; fn()) r.writeln;
  }
  else fn().writeln;
}
void runSolver() {
  problem();
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
