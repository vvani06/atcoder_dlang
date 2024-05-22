void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto RND = Xorshift(0);

  int N = scan!int;
  int[][] A = scan!int(N * N).chunks(N).array;

  struct Coord {
    int r, c;
  }

  struct Path {
    char move;
    Coord to;
  }

  // 積荷を持ってないクレーン用のグラフ
  auto freeCraneGraph = [
    ["..R.", "..R.", "..RD", "..RD", "...D"],
    [".U..", ".U..", "...D", "...D", "...D"],
    [".U..", ".U..", "...D", "...D", "...D"],
    [".U..", ".U..", "...D", "...D", "...D"],
    [".U..", "LU..", "L...", "L...", "L..."],
  ];
  // 積荷フリー状態なクレーン用のグラフ
  auto workCraneGraph = [
    ["..R.", "..R.", "..RD", "..RD", "...D"],
    ["..R.", ".UR.", "LU..", "..R.", "L..D"],
    ["..R.", ".UR.", "L...", "..R.", "L..D"],
    ["..R.", ".UR.", "L...", "..RD", "L..D"],
    ["..R.", ".U..", "LU..", "L...", "L..."],
  ];
  char[char] MOVE_REV = ['L': 'R', 'R': 'L', 'U': 'D', 'D': 'U'];

  Path[][Coord][2] memoPathes;
  Path[] pathes(Coord from, bool free) {
    if (from in memoPathes[free]) {
      return memoPathes[free][from];
    }

    Path[] ret;
    auto graph = free ? freeCraneGraph : workCraneGraph;
    foreach(d, c; graph[from.r][from.c]) {
      if (c == '.') continue;

      if (d == 0) ret ~= Path(c, Coord(from.r, from.c - 1));
      else if (d == 1) ret ~= Path(c, Coord(from.r - 1, from.c));
      else if (d == 2) ret ~= Path(c, Coord(from.r, from.c + 1));
      else if (d == 3) ret ~= Path(c, Coord(from.r + 1, from.c));
    }
    return memoPathes[free][from] = ret;
  }

  Path[] route(Coord from, bool free, Coord to) {
    Path[][] froms = new Path[][](N, N);
    froms[from.r][from.c].move = 1;

    for(auto queue = DList!Coord(from); !queue.empty;) {
      auto cur = queue.front;
      queue.removeFront;

      foreach(path; pathes(cur, free)) {
        auto next = path.to;
        if (froms[next.r][next.c].move != char.init) continue;

        froms[next.r][next.c] = Path(path.move, cur);
        if (next == to) break;
        queue.insertBack(next);
      }
    }

    Path[] ret;
    while(to != from) {
      auto path = froms[to.r][to.c];
      if (path.move == char.init) throw new Exception("Illegal Move");
      ret ~= Path(path.move, to);
      to = path.to;
    }
    return ret.reverse.array;
  }

  enum OrderType { Wait, Pick, Drop, Bomb, Move }
  struct Order {
    OrderType type = OrderType.Wait;
    Coord coord;

    bool priorColumnMove() {
      return type == OrderType.Pick;
    }
  }

  struct Crane {
    int id;
    int item;
    Coord coord;
    Order currentOrder;
    DList!Order nextOrders;
    bool destroyed;

    this(int id) {
      this.id = id;
      item = -1;
      coord = Coord(id, 0);
      currentOrder = Order();
    }

    void putOrder(Order order) {
      nextOrders.insertBack(order);
    }

    Order order() {
      if (currentOrder.type == OrderType.Wait && !nextOrders.empty) {
        currentOrder = nextOrders.front;
        nextOrders.removeFront;
      }
      return currentOrder;
    }

    bool waiting() {
      return order.type == OrderType.Wait;
    }
  }

  struct State {
    int[][] baseStocks;
    DList!(int)[] stocks;
    int[] stockedRowByItem;
    Crane[] cranes;

    int[] pulledByRow;
    int[] pushedByRow;
    bool[] pushedByItem;
    RedBlackTree!int heads;

    int turn;
    int[][] grid;
    Coord[int] coordByItem;
    int[][] outputs;
    string[] moves;
    
    this(int[][] stocks) {
      baseStocks = stocks.map!"a.dup".array;
      pulledByRow = 1.repeat(N).array;
      pushedByRow = new int[](N);
      pushedByItem = new bool[](N ^^ 2);
      outputs = new int[][](N, 0);
      moves = new string[](N, 0);

      heads = iota(0, N^^2, N).redBlackTree;
      cranes = N.iota.map!(i => Crane(i)).array;

      this.stocks = stocks.map!(a => DList!int(a)).array;

      stockedRowByItem = new int[](N^^2);
      foreach(r; 0..N) foreach(c; 0..N) {
        stockedRowByItem[stocks[r][c]] = r;
      }

      grid = N.iota.map!(_ => (-1).repeat(N).array).array;
      foreach(r; 0..N) {
        grid[r][0] = this.stocks[r].front;
        coordByItem[grid[r][0]] = Coord(r, 0);
        this.stocks[r].removeFront;
      }
    }

    int costForItem(int itemId) {
      int[] calcSubCosts(int n) {
        int[] ret = n % N == 0 ? 0.repeat(N).array : calcSubCosts(n - 1);

        int r = stockedRowByItem[n];
        int offset = pushedByRow[r];
        int depth = baseStocks[r][offset..$].countUntil(n).to!int;
        ret[r].chmax(depth + 1);
        return ret;
      }
      
      return calcSubCosts(itemId).sum;
    }

    void putOrder(int craneId, Order order) {
      cranes[craneId].putOrder(order);
    }

    int rowStockCost(int r) {
      if (stocks[r].empty) return int.max;

      // stocks[r].array.deb;
      return stocks[r].array.map!(n => (n % N) - pushedByRow[n / N]).sum;
    }

    bool isCoordEmpty(int r, int c) { return isCoordEmpty(Coord(r, c)); }
    bool isCoordEmpty(Coord coord) {
      if (grid[coord.r][coord.c] != -1) return false;
      if (cranes.any!(t => t.coord == coord)) return false;

      return true;
    }

    Coord findEmptyCoord() {
      foreach(r; 0..N) foreach(c; 1..4) {
        auto coord = Coord(r, c);
        if (isCoordEmpty(coord)) return coord;
      }

      return Coord(-1, -1);
    }

    void simulate() {
      // クレーンのシミュレーション
      foreach(i; 0..N) {
        auto crane = &cranes[i];
        if (crane.destroyed) continue;
        
        auto order = cranes[i].order;
        if (order.type == OrderType.Bomb) {
          crane.destroyed = true;
          moves[i] ~= 'B';
          continue;
        }

        if (order.type == OrderType.Wait) {
          moves[i] ~= '.';
          continue;
        }

        auto from = crane.coord;
        auto to = order.coord;
        if (from != to) {
          if (order.priorColumnMove()) {
            if (from.c != to.c) {
              crane.coord.c += from.c < to.c ? 1 : -1;
              moves[i] ~= from.c < to.c ? 'R' : 'L';
            } else {
              crane.coord.r += from.r < to.r ? 1 : -1;
              moves[i] ~= from.r < to.r ? 'D' : 'U';
            }
          } else {
            if (from.r != to.r) {
              crane.coord.r += from.r < to.r ? 1 : -1;
              moves[i] ~= from.r < to.r ? 'D' : 'U';
            } else {
              crane.coord.c += from.c < to.c ? 1 : -1;
              moves[i] ~= from.c < to.c ? 'R' : 'L';
            }
          }
          continue;
        }

        if (order.type == OrderType.Pick) {
          moves[i] ~= 'P';
          crane.item = grid[from.r][from.c];
          grid[from.r][from.c] = -1;
          coordByItem.remove(crane.item);
          crane.currentOrder = Order();
          continue;
        }

        if (order.type == OrderType.Drop) {
          moves[i] ~= 'Q';
          grid[from.r][from.c] = crane.item;
          coordByItem[crane.item] = from;
          crane.item = -1;
          crane.currentOrder = Order();
          continue;
        }

        moves[i] ~= '.';
      }
      
      // 搬出口の処理
      foreach(r; 0..N) {
        if (grid[r][N - 1] == -1) continue;

        auto item = grid[r][N - 1];
        outputs[r] ~= item;
        coordByItem.remove(item);
        grid[r][N - 1] = -1;
        pushedByRow[r]++;

        heads.removeKey(item);
        pushedByItem[item] = true;
        if (item % N != N - 1) heads.insert(item + 1);
      }

      // 搬入口からの補充
      foreach(r; 0..N) {
        if (this.stocks[r].empty || !isCoordEmpty(r, 0)) continue;

        grid[r][0] = this.stocks[r].front;
        coordByItem[grid[r][0]] = Coord(r, 0);
        this.stocks[r].removeFront;
      }
    }

    bool noOrder() {
      return cranes.all!(c => c.destroyed || c.order.type == OrderType.Wait);
    }
  }

  State state = State(A);
  // foreach(i; 1..5) state.order(i, Order(OrderType.Bomb));

  foreach(i; 0..N) {
    int delivered;
    for(int t = 0; t < N - 2; t++) {
      if (delivered >= 5) break;

      state.putOrder(i, Order(OrderType.Pick, Coord(i, 0)));
      if (t == 0 && A[i][delivered] == i * N + delivered) {
        state.putOrder(i, Order(OrderType.Drop, Coord(i, N - 1)));
        t--;
        delivered++;
      } else {
        state.putOrder(i, Order(OrderType.Drop, Coord(i, N - 2 - t)));
      }
    }

    if (i > 0) {
      state.putOrder(i, Order(OrderType.Bomb));
    }
  }
  state.putOrder(1, Order(OrderType.Pick, Coord(1, N - 2)));
  state.putOrder(1, Order(OrderType.Move, Coord(1, N - 1)));

  foreach(_; 0..1000) {
    state.costForItem(0).deb;
    state.costForItem(20).deb;
    // state.pushedByRow.deb;
    if (state.noOrder || state.pushedByRow.sum == N^^2) break;

    state.simulate();

    if (state.cranes[0].waiting) {
      foreach(head; state.heads) {
        if (!(head in state.coordByItem)) continue;

        state.putOrder(0, Order(OrderType.Pick, state.coordByItem[head]));
        state.putOrder(0, Order(OrderType.Drop, Coord(head / N, N - 1)));
      }
    }

    if (state.cranes[0].waiting) {
      int rowCost = int.max;
      int targetRow;

      foreach(r; 0..N) if (rowCost.chmin(state.rowStockCost(r))) targetRow = r;
      if (rowCost < int.max) {
        state.putOrder(0, Order(OrderType.Pick, Coord(targetRow, 0)));
        state.putOrder(0, Order(OrderType.Drop, state.findEmptyCoord()));
      }
    }
  }

  pathes(Coord(1, 1), true).deb;
  pathes(Coord(1, 1), false).deb;

  foreach(move; state.moves) move.writeln;
}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
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
