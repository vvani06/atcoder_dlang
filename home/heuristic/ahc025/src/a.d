import std;

void main() {
  int N = scan!int;
  int D = scan!int;
  int Q = scan!int;

  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

  struct Items {
    RedBlackTree!int[] sets;
    RedBlackTree!int fixedItems, freeItems;
    bool[26] fixed;

    void initialize() {
      freeItems = N.iota.redBlackTree;
      fixedItems = new int[](0).redBlackTree;
    }

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

    void fix(int item, int bag) {
      fixedItems.insert(item);
      freeItems.removeKey(item);
      fixed[bag] = true;
    }

    bool isFree(int item) {
      return (item in freeItems);
    }

    int choiceFreeItem(int bag) {
      foreach(s; sets[bag].array.randomShuffle) {
        if (isFree(s)) return s;
      }
      return -1;
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

      auto ls = sets[l].dup;
      auto rs = sets[r].dup;
      ls.insert(item);
      rs.removeKey(item);

      if (ls.empty) return -1;
      if (rs.empty) return 1;
      if (comparedCount >= Q) throw new StringException("overcompared");

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
      if (cache[l][r] != 9) return cache[l][r];

      if (comparedCount >= Q) throw new StringException("overcompared");

      auto la = sets[l].array;
      auto ra = sets[r].array;
      writefln("%s %s %(%s %) %(%s %)", la.length, ra.length, la, ra);
      stdout.flush();
      comparedCount++;

      auto ret = scan();
      auto result = ret == "<" ? -1 : ret == "=" ? 0 : 1;
      return setComparedCache(l, r, result);
    }

    int setComparedCache(int l, int r, int comparedResult) {
      cache[l][r] = comparedResult;
      cache[r][l] = comparedResult * -1;
      return comparedResult;
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
    auto items = Items(sets); {
      items.initialize();
    }
    auto comparer = Comparer(0, items); {
      comparer.initialize();
    }

    void randomSwap(int fixedFrom = -1) {
      auto toSwap = D.iota.randomSample(2).array;
      if (fixedFrom != -1) {
        toSwap[1] = fixedFrom;
        toSwap[0] = D.iota.filter!(a => a != fixedFrom).array.choice();
      }

      int l = toSwap[0];
      int r = toSwap[1];
      auto before = comparer.compare(l, r);
      if (before == 0) return;
      
      // l < r として、 ランダムに1つ r => l してもう一回測る
      if (before == 1) swap(l, r);
      if (sets[r].array.length == 1) return;

      auto swappee = items.choiceFreeItem(r);
      if (swappee == -1) return;

      auto after = comparer.compareSwapped(l, r, swappee);

      // l <= r が維持されているなら実際に入れ替える
      if (after != 1) {
        writefln("# random swap %s: %s => %s", swappee, r, l);
        comparer.swap(l, r, swappee);
        comparer.setComparedCache(l, r, after);
      }
    }

    void swapLargest() {
      int largest;
      foreach(i; 1..D) {
        const c = comparer.compare(largest, i);
        if (c == -1) largest = i;
      }
      writefln("# largest bag id: %s", largest);

      if (sets[largest].array.length == 1) {
        items.fix(sets[largest].front, largest);
        return;
      }

      auto swappee = items.choiceFreeItem(largest);
      if (swappee == -1) return;

      auto sizes = D.iota.map!(a => [a, sets[a].length.to!int]).array.sort!"a[1] > b[1]";
      foreach(i; sizes.map!"a[0]") {
        if (i == largest || items.fixed[i]) continue;

        auto after = comparer.compareSwapped(i, largest, swappee);

        // l <= r が維持されているなら実際に入れ替える
        if (after != 1) {
          writefln("# largest swap %s: %s => %s", swappee, largest, i);
          comparer.swap(i, largest, swappee);
          comparer.setComparedCache(i, largest, after);
          items.fix(swappee, i);
          return;
        }
      }

      // 巨大なアイテムしか残っていない
      foreach(i; sizes.map!"a[0]") {
        if (i == largest || items.fixed[i]) continue;
        
        // 強制的に入れ替えて、そのアイテムは固定する
        writefln("# largest swap2 %s: %s => %s", swappee, largest, i);
        comparer.swap(i, largest, swappee);
        items.fix(swappee, i);
        break;
      }

      foreach(_; 0..D) {
        randomSwap(largest);
      }

      // int smallest;
      // foreach(i; 1..D) {
      //   const c = comparer.compare(smallest, i);
      //   if (c == 1) smallest = i;
      // }
      // foreach(_; )
    }

    for(int turn = 0; comparer.canCompare(); turn++) {
      if (elapsed(1800)) break;
      
      writefln("#c %(%s %)", items.asAns());
      try {
        if (comparer.comparedCount < Q / 2 && turn % D == D - 1) {
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
