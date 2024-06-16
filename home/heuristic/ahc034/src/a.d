void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto RND = Xorshift(0);

  int N = scan!int;
  int[][] H = scan!int(N * N).chunks(N).array;

  struct Coord {
    int r, c;

    Coord add(Coord other) {
      return Coord(r + other.r, c + other.c);
    }

    enum Coord Invalid = Coord(-1, -1);
    enum Coord[char] Deltas = [
      'L': Coord(0, -1),
      'R': Coord(0, 1),
      'U': Coord(-1, 0),
      'D': Coord(1, 0),
    ];
  }

  struct Field {
    int[][] H;

    this(int[][] h) {
      H = h.map!"a.dup".array;
    }

    int at(Coord coord) {
      return H[coord.r][coord.c];
    }

    long scoreBase() {
      return H.joiner.map!"a.abs".sum;
    }
  }

  struct Strategy {
    Field field;
    string route;
    int minLimit;
    long score;

    this(int[][] h, string r) {
      field = Field(h);
      route = r;

      auto t = simulate();
      score = t[0];
      minLimit = t[1];
    }

    Tuple!(long, int) simulate() {
      int maxLimit = int.min;
      int minLimit;
      int[] stocks;
      long cost;
      
      {
        Coord cur;
        int stock = -field.at(cur);
        foreach(move; route) {
          stock += field.at(cur);
          cost += field.at(cur).abs;
          cost += 100;
          stocks ~= stock;
          maxLimit.chmax(stock);
          minLimit.chmin(stock);
          cur = cur.add(Coord.Deltas[move]);
        }
      }

      cost += stocks.map!(s => s + minLimit.abs).sum;
      cost += minLimit.abs * 2;
      return tuple(10L^^9 * field.scoreBase / cost, minLimit);
    }

    void writeAns() {
      {
        Coord cur;
        int stock;
        if (minLimit < 0) {
          writefln("+%s", -minLimit);
          stock = -minLimit;
        }

        foreach(move; route) {
          writeln(move);
          cur = cur.add(Coord.Deltas[move]);

          auto h = field.at(cur);
          if (h != 0) {
            stock += h;
            writefln("%s%s", h > 0 ? "+" : "-", h.abs);
          }
        }
        if (stock != 0) writefln("%s%s", stock < 0 ? "+" : "-", stock.abs);
      }
    }
  }

  string route; {
    route ~= 'R'.repeat(N - 1).to!string;
    route ~= "D";
    foreach(_; 0..N / 2 - 1) {
      route ~= 'L'.repeat(N - 2).to!string;
      route ~= "D";
      route ~= 'R'.repeat(N - 2).to!string;
      route ~= "D";
    }
    route ~= 'L'.repeat(N - 1).to!string;
    route ~= 'U'.repeat(N - 1).to!string;
    // route.split.joiner(" ").each!writeln;
  }

  string route2; {
    route2 ~= 'D'.repeat(N - 1).to!string;
    route2 ~= "R";
    foreach(_; 0..N / 2 - 1) {
      route2 ~= 'U'.repeat(N - 2).to!string;
      route2 ~= "R";
      route2 ~= 'D'.repeat(N - 2).to!string;
      route2 ~= "R";
    }
    route2 ~= 'U'.repeat(N - 1).to!string;
    route2 ~= 'L'.repeat(N - 1).to!string;
    // route.split.joiner(" ").each!writeln;
  }

  Strategy bestStrategy;
  long bestScore;
  foreach(r; [route, route2]) {
    auto strategy = Strategy(H, r);
    strategy.score.deb;
    if (bestScore.chmax(strategy.score)) {
      bestStrategy = strategy;
    }
  }

  auto strategy = Strategy(H, route2);
  bestStrategy.writeAns();
}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
// void deb(T ...)(T t){ debug {  }}
T[] divisors(T)(T n) { T[] ret; for (T i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
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
  problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
