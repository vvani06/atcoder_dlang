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
    ["..R.", "L.R.", "..RD", "..RD", "...D"],
    ["..R.", "LUR.", "LU..", "..R.", "L..D"],
    ["..R.", "LUR.", "L...", "..R.", "L..D"],
    ["..R.", "LUR.", "L...", "..RD", "L..D"],
    ["..R.", "LU..", "LU..", "L...", "L..."],
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

  enum OrderType { Wait, Pick, Drop, Bomb, Move }
  struct Order {
    OrderType type = OrderType.Wait;
    Coord coord;

    bool priorColumnMove() {
      return type == OrderType.Pick;
    }
  }

  class Crane {
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

    bool free() {
      return item == -1;
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
    
    Path[] route(Coord to, ref int[][] grid) {
      auto from = coord;
      Path[][] froms = new Path[][](N, N);
      froms[from.r][from.c].move = 1;

      for(auto queue = DList!Coord(from); !queue.empty;) {
        auto cur = queue.front;
        queue.removeFront;

        foreach(path; pathes(cur, free)) {
          auto next = path.to;
          if (!free && next.c < N - 1 && grid[next.r][next.c] != -1 && next != to) continue;
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

    override string toString() {
      return "[#%s / % 3s] (% 2s, % 2s) <%s> <%s>".format(id, item, coord.r, coord.c, currentOrder, nextOrders.array);
    }
  }

  enum ItemState {
    Unplaced,
    Placed,
    Moved,
    Waiting,
    Picked,
    Delivered,
  }

  struct State {
    int[][] baseStocks;
    DList!(int)[] stocks;
    int[] stockedRowByItem;
    ItemState[] itemStates;
    RedBlackTree!int heads;

    int[] pulledByRow;
    int[] pushedByRow;
    bool[] pushedByItem;

    int[][] grid;
    Coord[int] coordByItem;

    Crane[] cranes;

    int[][] outputs;
    Path[][] moves;
    
    this(int[][] stocks) {
      baseStocks = stocks.map!"a.dup".array;
      pulledByRow = 1.repeat(N).array;
      pushedByRow = new int[](N);
      pushedByItem = new bool[](N ^^ 2);
      itemStates = (ItemState.Unplaced).repeat(N ^^ 2).array;
      heads = iota(0, N^^2, N).redBlackTree;

      outputs = new int[][](N, 0);
      cranes = N.iota.map!(i => new Crane(i)).array;
      moves = N.iota.map!(i => [Path(0, Coord(i, 0))]).array;

      this.stocks = stocks.map!(a => DList!int(a)).array;
      stockedRowByItem = new int[](N^^2);
      foreach(r; 0..N) foreach(c; 0..N) {
        stockedRowByItem[stocks[r][c]] = r;
      }

      grid = N.iota.map!(_ => (-1).repeat(N).array).array;
      foreach(r; 0..N) {
        auto item = this.stocks[r].front;
        this.stocks[r].removeFront;

        grid[r][0] = item;
        coordByItem[item] = Coord(r, 0);
        itemStates[item] = ItemState.Placed;
      }
    }

    int costForItem(int itemId) {
      int[] calcSubCosts(int n) {
        int[] ret = n % N == 0 ? 0.repeat(N).array : calcSubCosts(n - 1);

        int r = stockedRowByItem[n];
        int offset = pulledByRow[r];
        int depth = baseStocks[r][offset..$].countUntil(n).to!int;
        ret[r].chmax(depth + 1);
        return ret;
      }
      
      return calcSubCosts(itemId).sum;
    }

    int headOfItem(int itemId) {
      auto r = stockedRowByItem[itemId];
      foreach(i; 0..N) {
        auto pre = baseStocks[r][i];
        if (itemStates[pre] == ItemState.Placed) return pre;
        if (pre == itemId) break;
      }

      return -1;
    }

    int[] nextItems() {
      // heads.array.map!(i => [costForItem(i), i]).array.deb;
      return heads.array.map!(i => [costForItem(i), i]).array.sort.map!"a[1]".array;
    } 
    
    bool isCoordEmpty(int r, int c) { return isCoordEmpty(Coord(r, c)); }
    bool isCoordEmpty(Coord coord) {
      if (grid[coord.r][coord.c] != -1) return false;
      // if (cranes.any!(t => t.coord == coord)) return false;

      return true;
    }

    Coord findEmptyCoord() {
      foreach(c; [
        Coord(1, 3), Coord(1, 2), Coord(2, 2), 
        Coord(3, 2), Coord(3, 3), Coord(2, 3), 
        Coord(4, 0), Coord(3, 0), Coord(2, 0), Coord(1, 0), Coord(0, 0),
      ]) {
        if (grid[c.r][c.c] == -1) return c;
      }

      throw new Exception("No Space Available");
    }

    void simulate() {
      // 搬出口の処理
      foreach(r; 0..N) {
        if (grid[r][N - 1] == -1) continue;

        auto item = grid[r][N - 1];
        deb("delivered: ", item);
        itemStates[item] = ItemState.Delivered;
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

        auto item = this.stocks[r].front;
        grid[r][0] = item;
        coordByItem[item] = Coord(r, 0);
        itemStates[item] = ItemState.Placed;
        pulledByRow[r]++;
        this.stocks[r].removeFront;
      }
    }

    Crane waitingNearestCrane(Coord to) {
      Crane ret;
      int minDistance = int.max;
      foreach(i; 0..N) {
        auto crane = cranes[i];
        if (!crane.waiting || crane.destroyed) continue;

        auto d = crane.route(to, grid).length.to!int;
        if (minDistance.chmin(d)) {
          ret = cranes[i];
        }
      }

      return ret;
    }
  }

  State state = State(A);

  foreach(turn; 0..500) {
    turn.deb;

    foreach(toPick; state.nextItems[0..min(3, $)]) {
      // deb(state.nextItems, toPick, state.itemStates[toPick]);
      if (state.itemStates[toPick] != ItemState.Placed && state.itemStates[toPick] != ItemState.Moved) toPick = state.headOfItem(state.nextItems[0]);
      deb(state.nextItems, toPick);
      if (toPick != -1 && (state.itemStates[toPick] == ItemState.Placed || state.itemStates[toPick] == ItemState.Moved)) {
        auto coordToPick = state.coordByItem[toPick];
        auto crane = state.waitingNearestCrane(coordToPick);

        if (crane) {
          crane.putOrder(Order(OrderType.Pick, coordToPick));
          state.itemStates[toPick] = ItemState.Waiting;

          if (toPick in state.heads) {
            crane.putOrder(Order(OrderType.Drop, Coord(toPick / N, N - 1)));
          } else {
            auto toMove = state.findEmptyCoord();
            state.grid[toMove.r][toMove.c] = -2;
            crane.putOrder(Order(OrderType.Drop, toMove));
          }
          crane.putOrder(Order(OrderType.Move, Coord(4, 2)));
        }
      }
    }

    foreach(crane; state.cranes) {
      if (crane.waiting() && crane.coord == Coord(4, 2)) {
        crane.putOrder(Order(OrderType.Move, Coord(0, 2)));
        crane.putOrder(Order(OrderType.Move, Coord(4, 4)));
        crane.putOrder(Order(OrderType.Move, Coord(4, 4)));
        crane.putOrder(Order(OrderType.Move, Coord(4, 2)));
      }
    }

    int[Coord] cur, next;
    foreach(i, crane; state.cranes.enumerate(0)) {
      if (crane.destroyed) continue;

      cur[crane.coord] = i;
      next[crane.coord] = i;
    }
    
    Path[] craneMoves = state.cranes.map!(c => Path('.', c.coord)).array;
    foreach(i, crane; state.cranes) {
      if (crane.waiting() || crane.destroyed) continue;

      auto order = crane.order();
      if (crane.coord == order.coord) {
        if (order.type == OrderType.Pick) {
          auto item = state.grid[crane.coord.r][crane.coord.c];
          state.grid[crane.coord.r][crane.coord.c] = -1;
          crane.item = item;
          state.itemStates[item] = ItemState.Picked;
          state.coordByItem[item] = Coord(-1, -1);
          craneMoves[i] = Path('P', crane.coord);
        } else if (order.type == OrderType.Drop) {
          state.grid[crane.coord.r][crane.coord.c] = crane.item;
          state.itemStates[crane.item] = crane.coord.c == N - 1 ? ItemState.Delivered : ItemState.Moved;
          state.coordByItem[crane.item] = crane.coord;
          crane.item = -1;
          craneMoves[i] = Path('Q', crane.coord);
        }
      } else {
        crane.deb;
        // state.grid.each!deb;
        auto nextPath = crane.route(crane.order.coord, state.grid)[0];
        auto from = crane.coord;
        auto to = nextPath.to;
        if (to in next) continue;
        if (cur.get(to, -1) == next.get(from, -2)) continue;
        
        enum LBPickerCoords = [Coord(3, 0), Coord(4, 0)];
        if (from == Coord(4, 2) && LBPickerCoords.any!(c => c in cur)) continue;

        craneMoves[i] = nextPath;
        next.remove(from);
        next[to] = i.to!int;
      }
    }

    foreach(i, m; craneMoves) {
      auto crane = state.cranes[i];
      state.moves[i] ~= m;
      crane.coord = m.to;
      
      if (crane.coord == crane.order.coord) {
        if (crane.order.type == OrderType.Pick && !crane.free) crane.currentOrder = Order();
        else if (crane.order.type == OrderType.Drop && crane.free) crane.currentOrder = Order();
        else if (crane.order.type == OrderType.Move) crane.currentOrder = Order();
      }
    }

    state.cranes.each!deb;
    state.simulate();
    if (state.pushedByRow.sum == N^^2) break;
  }

  foreach(move; state.moves) {
    string s;
    foreach(c; move[1..$]) s ~= c.move;
    s.writeln;
  }
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
