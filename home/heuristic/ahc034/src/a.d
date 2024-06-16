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

  struct State {
    int t, l, b, r;
    Coord cur;

    this(int id) {
      t = id % 21; id /= 21;
      l = id % 21; id /= 21;
      b = id % 21; id /= 21;
      r = id % 21; id /= 21;

      int y, x;
      y = (id % 2 == 0) ? t : b;
      id /= 2;
      x = (id % 2 == 0) ? l : r;
      cur = Coord(y, x);
    }

    this(int t, int l, int b, int r, Coord c) {
      this.t = t;
      this.l = l;
      this.b = b;
      this.r = r;
      this.cur = c;
    }

    int toId() {
      int ret;
      int offset = 1;
      
      ret += t * offset; offset *= 21;
      ret += l * offset; offset *= 21;
      ret += b * offset; offset *= 21;
      ret += r * offset; offset *= 21;
      ret += cur.r == b ? offset : 0; offset *= 2;
      ret += cur.c == r ? offset : 0; 
      return ret;
    }

    Tuple!(State, string) fillRow() {
      int nt = t;
      int nb = b;
      if (cur.r == t) nt++; else nb--;

      Coord ncur = cur;
      string moves;
      if (cur.c == l) {
        if (r > l) moves ~= 'R'.repeat((r - l).abs).to!string;
        else moves ~= 'L'.repeat((r - l).abs).to!string;
        ncur.c = r;
      } else {
        if (r > l) moves ~= 'L'.repeat((r - l).abs).to!string;
        else moves ~= 'R'.repeat((r - l).abs).to!string;
        ncur.c = l;
      }

      if (cur.r == t) {
        ncur.r++;
        if (cur.r != b) moves ~= 'D';
      } else {
        ncur.r--;
        if (cur.r != t) moves ~= 'U';
      }

      auto next = State(nt, l, nb, r, ncur);
      return tuple(next, moves);
    }

    Tuple!(State, string) fillColumn() {
      int nl = l;
      int nr = r;
      if (cur.c == l) nl++; else nr--;

      Coord ncur = cur;
      string moves;
      if (cur.r == t) {
        if (b > t) moves ~= 'D'.repeat((b - t).abs).to!string;
        else  moves ~= 'U'.repeat((b - t).abs).to!string;
        ncur.r = b;
      } else {
        if (b > t) moves ~= 'U'.repeat((b - t).abs).to!string;
        else moves ~= 'D'.repeat((b - t).abs).to!string;
        ncur.r = t;
      }

      if (cur.c == l) {
        ncur.c++;
        if (cur.c != r) moves ~= 'R';
      } else {
        ncur.c--;
        if (cur.c != l) moves ~= 'L';
      }

      auto next = State(t, nl, b, nr, ncur);
      return tuple(next, moves);
    }
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

  struct Cursor {
    long cost;
    int minLimit;
    int[] stocks = [0];
    string route = "";

    int opCmp(Cursor other) {
      return cmp([cost, -minLimit], [other.cost, -other.minLimit]);
    }

    void walk(Field field, Coord from, Coord to, string route) {
      cost -= stocks.map!(s => s + minLimit.abs).sum;
      cost -= minLimit.abs * 2;
      
      // [from, to].deb;
      // route.deb;

      Coord cur = from;
      int stock = stocks[$ - 1];
      foreach(move; route) {
        stock += field.at(cur);
        cost += field.at(cur).abs;
        cost += 100;
        stocks ~= stock;
        minLimit.chmin(stock);
        cur = cur.add(Coord.Deltas[move]);
      }

      cost += stocks.map!(s => s + minLimit.abs).sum;
      cost += minLimit.abs * 2;
      this.route ~= route;
    }

    Cursor dup() {
      return Cursor(cost, minLimit, stocks.dup, route);
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
        if (field.at(cur) > 0) {
          minLimit -= field.at(cur);
        }

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

        if (stock > 0) {
          foreach(_; 0..cur.r) {
            writeln("U");
            cur.r--;
          }
          foreach(_; 0..cur.c) {
            writeln("L");
            cur.c--;
          }
          writefln("%s", -stock);
        }
      }
    }
  }

  Field field = Field(H);
  auto initState = State(0, 0, N-1, N-1, Coord(0, 0));
  Cursor[int] memo;

  // auto ist = initState.fillRow()[0];
  // initState.fillRow().deb;
  // auto iss = State(ist.toId);
  // iss.deb;
  // iss.fillRow().deb;

  alias HeapItem = Tuple!(int, Cursor);
  memo[initState.toId] = Cursor();
  auto heap = [HeapItem(initState.toId, memo[initState.toId])].heapify!"a[1] > b[1]";

  while(!heap.empty) {
    auto top = heap.front;
    auto id = top[0];
    auto cursor = top[1];
    heap.removeFront;
    if (cursor != memo[id]) continue;

    // cursor.cost.deb;

    auto state = State(id);
    if (state.t > state.b || state.l > state.r) continue;

    if (state.t <= state.b) {
      auto to = state.fillRow();
      auto toC = cursor.dup;
      auto toId = to[0].toId;
      toC.walk(field, state.cur, to[0].cur, to[1]);
      if (!(toId in memo) || memo[toId] > toC) {
        memo[toId] = toC;
        heap.insert(tuple(toId, toC));
      }
    }
    if (state.l <= state.r) {
      auto to = state.fillColumn();
      auto toC = cursor.dup;
      auto toId = to[0].toId;
      toC.walk(field, state.cur, to[0].cur, to[1]);
      if (!(toId in memo) || memo[toId] > toC) {
        memo[toId] = toC;
        heap.insert(tuple(toId, toC));
      }
    }
  }

  long bestScore;
  Cursor bestCursor;
  Strategy bestStrategy;
  foreach(id, cursor; memo) {
    auto state = State(id);
    if (state.l > state.r || state.t > state.b) {
      // cursor.route.deb;
      auto strategy = Strategy(H, cursor.route);
      if (bestScore.chmax(strategy.score)) {
        bestCursor = cursor;
        bestStrategy = strategy;
      }
    }
  }

  bestStrategy.writeAns();
  // state.fillRow().deb;
  // state.fillColumn().deb;
  // state.fillRow()[0].fillColumn().deb;
  // state.fillColumn()[0].fillColumn().deb;
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
