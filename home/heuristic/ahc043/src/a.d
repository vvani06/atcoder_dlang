void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int M = scan!int;
  int K = scan!int;
  int T = scan!int;
  int[][] IJ = scan!int(4 * M).chunks(4).array;

  enum DELTA_AROUND2 = zip(
    [-2, -1, -1, -1, 0, 0, 0, 0, 0, 1, 1, 1, 2],
    [0, -1, 0, 1, -2, -1, 0, 1, 2, -1, 0, 1, 0]
  );
  enum COST_RAIL = 100;
  enum COST_STATION = 5000;

  int asId(int r, int c) {
    return r * N + c; 
  }

  struct Coord {
    int r, c;

    this(int id) {
      this(id / N, id % N);
    }

    this(int r, int c) {
      this.r = r;
      this.c = c;
    }

    int distance(Coord other) {
      return abs(r - other.r) + abs(c - other.c);
    }

    string toString() {
      return format("(%2d, %2d)", r, c);
    }

    bool satisfied(BitArray ba) {
      return ba[asId(r, c)];
    }

    Coord[] around() {
      return DELTA_AROUND2
        .map!(d => [r + d[0], c + d[1]])
        .filter!(rc => min(rc[0], rc[1]) >= 0 && max(rc[0], rc[1]) < N)
        .map!(rc => Coord(rc[0], rc[1]))
        .array;
    }

    int[] aroundId() {
      return DELTA_AROUND2
        .map!(d => [r + d[0], c + d[1]])
        .filter!(rc => min(rc[0], rc[1]) >= 0 && max(rc[0], rc[1]) < N)
        .map!(rc => asId(rc[0], rc[1]))
        .array;
    }
  }

  struct Customer {
    int id;
    Coord from, to;

    int value() { return from.distance(to); }

    string toString() {
      return format("Customer #%04d $%2d [%s => %s]", id, value(), from, to);
    }

    bool satisfied(BitArray ba) {
      return from.satisfied(ba) && to.satisfied(ba);
    }
  }

  auto customers = IJ.enumerate(0).map!(ij => Customer(ij[0], Coord(ij[1][0], ij[1][1]), Coord(ij[1][2], ij[1][3]))).array;
  auto froms = (N^^2).iota.map!(_ => BitArray(false.repeat(M).array)).array;
  auto tos = (N^^2).iota.map!(_ => BitArray(false.repeat(M).array)).array;
  foreach(customer; customers) {
    foreach(id; customer.from.aroundId()) froms[id][customer.id] = true;
    foreach(id; customer.to.aroundId()) tos[id][customer.id] = true;
  }

  long money = K;
  int bestFrom, bestTo, bestValue;
  foreach(f; 0..N^^2 - 1) {
    auto fromSatisfied = froms[f];
    auto fc = Coord(f / N, f % N);
    foreach(t; f + 1..N^^2) {
      auto tc = Coord(t / N, t % N);
      if (money < fc.distance(tc) * COST_RAIL + COST_STATION*2) continue;

      auto toSatisfied = tos[t];
      auto satisfied = fromSatisfied & toSatisfied;

      auto value = satisfied.bitsSet.map!(c => customers[c].value * 100_000).sum;
      value += (fromSatisfied ^ toSatisfied).bitsSet.map!(c => customers[c].value).sum;
      value -= Coord(f).distance(Coord(t));
      if (bestValue.chmax(value)) {
        bestFrom = f;
        bestTo = t;
      }
    }
  }
  deb(Coord(bestFrom), Coord(bestTo), bestValue);

  int turn;
  void dfs(Coord cur, Coord pre, Coord goal) {
    int type;
    if (cur == pre || cur == goal) {
      type = 0;
    } else if (cur.r != pre.r && cur.r == goal.r) {
      type = goal.c > cur.c ? 5 : 4;
    } else if (cur.r != pre.r) {
      type = 2;
    } else if (cur.c != pre.c) {
      type = 1;
    }
    if (cur != pre) writefln("%s %s %s", type, cur.r, cur.c);
    turn++;
    if (cur == goal) return;

    auto next = cur;
    if (cur.r == goal.r) next.c += goal.c > cur.c ? 1 : -1; else next.r++;
    dfs(next, cur, goal);
  }

  dfs(Coord(bestFrom), Coord(bestFrom), Coord(bestTo));
  writefln("%s %s %s", 0, Coord(bestFrom).r, Coord(bestFrom).c);
  foreach(_; turn..T) {
    writeln(-1);
  }
}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(lazy T t){ debug { write("# "); writeln(t); }}
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
