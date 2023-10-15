import std;

void main() {
  int N = scan!int;
  int D = scan!int;
  int Q = scan!int;

  struct Comparer {
    int comparedCount;

    int compare(T)(T l, T r) {
      auto la = l.array;
      auto ra = r.array;
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
    auto ans = () {
      auto ret = new int[](N);
      foreach(i, s; sets) foreach(n; s) ret[n] = i.to!int;
      return ret;
    };

    auto comparer = Comparer();
    while(comparer.canCompare()) {
      writefln("#c %(%s %)", ans());
      auto toSwap = D.iota.randomSample(2).array;

      int l = toSwap[0];
      int r = toSwap[1];
      auto before = comparer.compare(sets[l], sets[r]);

      if (!comparer.canCompare) break;
      if (before == 0) continue;
      
      // l < r として、 ランダムに1つ r => l してもう一回測る
      if (before == 1) swap(l, r);
      if (sets[r].array.length == 1) continue;

      auto swappee = sets[r].array.choice();
      sets[r].removeKey(swappee);
      sets[l].insert(swappee);
      auto after = comparer.compare(sets[l], sets[r]);

      // 大小が入れ替わるなら元に戻す
      if (after == 1) {
        sets[l].removeKey(swappee);
        sets[r].insert(swappee);
      }
    }
    
    comparer.finalize();
    writefln("%(%s %)", ans());
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
