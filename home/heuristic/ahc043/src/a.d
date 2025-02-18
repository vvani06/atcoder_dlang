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

  int[][] nexts = {
    int[][] ret = new int[][](N^^2, 0);

    foreach(r; 0..N) {
      int[] dr;
      if (r < N - 1) dr ~= N;
      if (r > 0) dr ~= -N;
      foreach(c; 0..N) {
        int[] dc;
        if (c < N - 1) dc ~= 1;
        if (c > 0) dc ~= -1;

        auto t = r*N + c;
        ret[t] ~= (dr ~ dc).map!(x => t + x).array;
      }
    }
    return ret;
  }();

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

  struct Order {
    int type, r, c;

    string asOutput() {
      return "%s %s %s".format(type, r, c);
    }

    int cost() {
      if (type == -1) return 0;
      if (type == 0) return COST_STATION;
      return COST_RAIL;
    }
  }

  class Cell {
    BitArray fromBit, toBit;
    RedBlackTree!int fromSet, toSet;

    this() {
      fromBit = BitArray(false.repeat(M).array);
      toBit = BitArray(false.repeat(M).array);
      fromSet = new int[](0).redBlackTree;
      toSet = new int[](0).redBlackTree;
    }
  }

  class State {
    Customer[] customers;
    long money;

    Cell[] grid;
    RedBlackTree!int fromCoveredSet, toCoveredSet;
    BitArray fromCoveredBit, toCoveredBit;
    int[] rail;
    Order[] orders;

    long income;
    BitArray fromSim, toSim;

    this(long money, Customer[] customers) {
      this.money = money;
      this.customers = customers;
      fromCoveredSet = new int[](0).redBlackTree;
      fromCoveredBit = BitArray(false.repeat(M).array);
      toCoveredSet = new int[](0).redBlackTree;
      toCoveredBit = BitArray(false.repeat(M).array);
      fromSim = BitArray(false.repeat(M).array);
      toSim = BitArray(false.repeat(M).array);
      rail = new int[](N ^^ 2);
      foreach(i; 0..N^^2) grid ~= new Cell();
      foreach(customer; customers) {
        foreach(id; customer.from.aroundId()) {
          grid[id].fromBit[customer.id] = true;
          grid[id].fromSet.insert(customer.id);
        }
        foreach(id; customer.to.aroundId()) {
          grid[id].toBit[customer.id] = true;
          grid[id].toSet.insert(customer.id);
        }
      }
    }

    RedBlackTree!int opposites(int coordId) {
      auto ret = new int[](0).redBlackTree;
      foreach(customer; grid[coordId].fromSet.array.map!(c => customers[c])) {
        ret.insert(customer.to.aroundId);
      }
      foreach(customer; grid[coordId].toSet.array.map!(c => customers[c])) {
        ret.insert(customer.from.aroundId);
      }
      return ret;
    }

    void applyStation(int coordId) {
      foreach(customer; grid[coordId].fromSet.array.map!(c => customers[c])) {
        foreach(id; customer.from.aroundId) {
          grid[id].fromBit[customer.id] = false;
          grid[id].fromSet.removeKey(customer.id);
        }
        if (!(customer.id in toCoveredSet)) fromCoveredSet.insert(customer.id);
        fromCoveredBit[customer.id] = true;
      }

      foreach(customer; grid[coordId].toSet.array.map!(c => customers[c])) {
        foreach(id; customer.to.aroundId) {
          grid[id].toBit[customer.id] = false;
          grid[id].toSet.removeKey(customer.id);
        }
        if (!(customer.id in fromCoveredSet)) toCoveredSet.insert(customer.id);
        toCoveredBit[customer.id] = true;
      }
    }

    Tuple!(int, int) findBestStationCoordId(int coordIdFrom) {
      auto fromSatisfied = grid[coordIdFrom].fromBit;
      auto fc = Coord(coordIdFrom);

      int ret;
      int best = int.min;
      foreach(t; opposites(coordIdFrom)) {
        auto tc = Coord(t);
        if (money < fc.distance(tc) * COST_RAIL + COST_STATION*2) continue;

        auto toSatisfied = grid[t].toBit;
        auto satisfied = fromSatisfied & toSatisfied;

        auto value = satisfied.bitsSet.map!(c => customers[c].value * 100_000).sum;
        value += (fromSatisfied ^ toSatisfied).bitsSet.map!(c => customers[c].value).sum;
        value -= fc.distance(Coord(t));
        if (best.chmax(value)) {
          ret = t;
        }
      }
      return tuple(ret, best);
    }

    int[] findFirstStationPair() {
      int[] ret; {
        int bestFrom, bestTo, bestValue;
        foreach(f; 0..N^^2 - 1) {
          auto to = findBestStationCoordId(f);
          if (bestValue.chmax(to[1])) {
            bestFrom = min(f, to[0]);
            bestTo = max(f, to[0]);
          }
        }
        ret ~= bestFrom;
        ret ~= bestTo;
      }

      foreach(s; ret) applyStation(s);
      return ret;
    }

    int[] findBestStations(int limit) {
      int[] ret;
      foreach(_; 0..limit) {
        int best, bestValue;
        foreach(t; 0..N^^2 - 1) {
          if (grid[t].fromSet.empty && grid[t].toSet.empty) continue;

          auto halfCovered = fromCoveredBit ^ toCoveredBit;
          auto toFullCovered = halfCovered & (grid[t].fromBit | grid[t].toBit);

          auto value = halfCovered.bitsSet.map!(c => customers[c].value).sum;
          value += toFullCovered.bitsSet.map!(c => customers[c].value * 5).sum;
          if (bestValue.chmax(value)) {
            best = t;
          }
        }

        if (bestValue == 0) break;
        ret ~= best;
        applyStation(best);
        [best, bestValue].deb;
      }
      return ret;
    }

    Order[] createOrder(int from) {
      int[] froms = (-1).repeat(N^^2).array;
      froms[from] = from;

      int goal = from;
      for(auto queue = DList!int(from); !queue.empty;) {
        auto cur = queue.front;
        queue.removeFront;
        if (rail[cur] != 0) {
          goal = cur;
          break;
        }

        foreach(next; nexts[cur]) {
          if (froms[next] != -1) continue;

          froms[next] = cur;
          queue.insertBack(next);
        }
      }

      Order[] ret;
      auto pre = Coord(goal);
      for(auto cur = goal; cur != from; cur = froms[cur]) {
        if (pre == Coord(cur)) continue;

        auto curc = Coord(cur);
        bool l, r, u, d;
        foreach(neigh; [pre, Coord(froms[cur])]) {
          if (neigh.r == curc.r - 1) u = true;
          if (neigh.r == curc.r + 1) d = true;
          if (neigh.c == curc.c - 1) l = true;
          if (neigh.c == curc.c + 1) r = true;
        }

        int type = {
          if (l && r) return 1;  
          if (u && d) return 2;
          if (l && d) return 3;
          if (l && u) return 4;
          if (r && u) return 5;
          if (r && d) return 6;
          throw new Exception("invalid Dir"); 
        }();
        ret ~= Order(type, curc.r, curc.c);
        rail[cur] = type;
        pre = curc;
      }

      foreach(t; [goal, from]) {
        if (rail[t] != 9) {
          ret ~= Order(0, t / N, t % N);
          rail[t] = 9;
          applyStation(t);
        }
      }
      return ret;
    }

    void simulate(int limit) {
      string[] outputs;
      long bestMoney = money;
      int turn, bestTurn;

      for (auto queue = DList!Order(orders); !queue.empty;) {
        if (turn == limit) break;

        auto order = queue.front;
        
        if (money >= order.cost) {
          money -= order.cost;
          queue.removeFront;
          outputs ~= order.asOutput();

          if (order.type == 0) {
            auto coord = Coord(order.r, order.c);
            foreach(c; customers) {
              if (coord.distance(c.from) <= 2) fromSim[c.id] = true;
              if (coord.distance(c.to) <= 2) toSim[c.id] = true;
            }
            income = (fromSim & toSim).bitsSet.map!(c => customers[c].value).sum;
          }
        } else {
          outputs ~= "-1";
        }
        money += income;
        turn++;
        if (bestMoney.chmax(money + income*(limit - turn))) {
          bestTurn = turn;
        }
      }

      foreach(_; 0..limit - turn) {
        outputs ~= "-1";
        money += income;
      }

      foreach(t, o; outputs) {
        writeln(t <= bestTurn ? o : "-1");
      }
      [bestTurn, bestMoney].deb;
    }
  }

  auto customers = IJ.enumerate(0).map!(ij => Customer(ij[0], Coord(ij[1][0], ij[1][1]), Coord(ij[1][2], ij[1][3]))).array;
  auto state = new State(K, customers);
  
  auto goals = state.findFirstStationPair();
  state.orders ~= Order(0, goals[0]/N, goals[0]%N);
  state.rail[goals[0]] = 9;
  state.orders ~= state.createOrder(goals[1]);
  foreach(_; 0..100) {
    if (elapsed(2800)) break;
    
    auto station = state.findBestStations(1);
    if (station.empty) break;
    state.orders ~= state.createOrder(station[0]);
  }

  state.simulate(T);
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
