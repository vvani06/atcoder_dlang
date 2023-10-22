import std;

void main() {
  int N = scan!int;
  int D = scan!int;
  int Q = scan!int;

  struct Items {
    RedBlackTree!int[] sets;

    auto asAns() {
      auto ret = new int[](N);
      foreach(i, s; sets) foreach(n; s) ret[n] = i.to!int;
      return ret;
    }

    bool swap(int l, int r, int item) {
      if (!(item in sets[r])) return false;

      sets[r].removeKey(item);
      sets[l].insert(item);
      return true;
    }
  }

  struct Comparer {
    int comparedCount;
    Items items;
    int[26][26] cache;

    auto sets() { return items.sets; }
    void initialize() {
      foreach(i; 0..26) foreach(j; 0..26) cache[i][j] = 9;
    }

    int compareSwapped(int l, int r, int item) {
      if (sets[l].empty && sets[r].empty) return 0;
      if (sets[l].empty) return -1;
      if (sets[r].empty) return 1;

      if (comparedCount >= Q) throw new StringException("overcompared");

      auto ls = sets[l].dup;
      auto rs = sets[r].dup;
      ls.insert(item);
      rs.removeKey(item);

      auto la = ls.array;
      auto ra = rs.array;
      writefln("%s %s %(%s %) %(%s %)", la.length, ra.length, la, ra);
      stdout.flush();
      comparedCount++;

      auto ret = scan();
      return ret == "<" ? -1 : ret == "=" ? 0 : 1;
    }

    int compare(int l, int r) {
      if (sets[l].empty && sets[r].empty) return 0;
      if (sets[l].empty) return -1;
      if (sets[r].empty) return 1;

      if (comparedCount >= Q) throw new StringException("overcompared");

      auto la = sets[l].array;
      auto ra = sets[r].array;
      writefln("%s %s %(%s %) %(%s %)", la.length, ra.length, la, ra);
      stdout.flush();
      comparedCount++;

      auto ret = scan();
      return ret == "<" ? -1 : ret == "=" ? 0 : 1;
    }

    void finalize() {
      while(comparedCount++ < Q) {
        writeln("1 1 1 2");
        stdout.flush();
        scan();
      }
    }

    void swap(int l, int r, int item) {
      if (!items.swap(l, r, item)) return;

      foreach(i; 0..26) foreach(j; [l, r]) {
        cache[i][j] = 9;
        cache[j][i] = 9;
      }
    }

    bool canCompare() {
      return comparedCount < Q;
    }
  }

  auto solve() {
    auto sets = D.iota.map!(_ => new int[](0).redBlackTree).array; {
      int[] setIds = new int[](N);
      foreach(d; 0..D) setIds[(N / D)*d..$] = d;
      setIds.randomShuffle();
      foreach(i, sid; setIds) sets[sid].insert(i.to!int);
    }
    auto items = Items(sets);
    auto comparer = Comparer(0, items);
    comparer.initialize();

    void randomSwap() {
      auto toSwap = D.iota.randomSample(2).array;

      int l = toSwap[0];
      int r = toSwap[1];
      auto before = comparer.compare(l, r);
      if (before == 0) return;
      
      // l < r として、 ランダムに1つ r => l してもう一回測る
      if (before == 1) swap(l, r);
      if (sets[r].array.length == 1) return;

      auto swappee = sets[r].array.choice();
      auto after = comparer.compareSwapped(l, r, swappee);

      // l <= r が維持されているなら実際に入れ替える
      if (after != 1) {
        comparer.swap(l, r, swappee);
      }
    }

    void swapLargest() {
      int largest;
      foreach(i; 1..D) {
        const c = comparer.compare(largest, i);
        if (c == -1) largest = i;
      }
      writefln("# largest bag id: %s", largest);

      auto sizes = D.iota.map!(a => [a, sets[a].length.to!int]).array.sort!"a[1] > b[1]";
      auto sr = sets[largest].dup;
      auto swappee = sr.array.choice();
      foreach(i; sizes.map!"a[0]") {
        if (i == largest) continue;

        auto after = comparer.compareSwapped(i, largest, swappee);

       // l <= r が維持されているなら実際に入れ替える
        if (after != 1) {
          comparer.swap(i, largest, swappee);
          return;
        }
      }

      // 巨大なアイテムしか残っていない
      // TODO
    }

    for(int turn = 0; comparer.canCompare(); turn++) {
      writefln("#c %(%s %)", items.asAns());
      try {
        if (turn % D == D - 1) {
          swapLargest();
        } else {
          randomSwap();
        }

      } catch(Exception e) { break; } 
    }
    
    comparer.finalize();
    writefln("%(%s %)", items.asAns());
    stdout.flush();
  }

  solve();
}

// ----------------------------------------------

string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
T[] divisors(T)(T n) { T[] ret; for (T i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }

// -----------------------------------------------
