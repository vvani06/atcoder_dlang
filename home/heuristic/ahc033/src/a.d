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

    static Coord Invalid = Coord(-1, -1);
  }

  struct Path {
    char move;
    Coord to;
  }

  enum OrderType { Wait, Pick, Drop, Bomb, Move, Keep }
  struct Order {
    OrderType type = OrderType.Wait;
    Coord coord;

    bool priorColumnMove() {
      return type == OrderType.Pick;
    }
  }

  class Crane {
    int id;
    string[][][] graphs;

    int item;
    Coord coord;
    Order currentOrder;
    DList!Order nextOrders;
    bool destroyed;

    this(int id, string[][][] graphs) {
      this.id = id;
      item = -1;
      coord = Coord(id, 0);
      currentOrder = Order();
      this.graphs = graphs;
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

    bool notWorking() {
      return order.type == OrderType.Wait || order.type == OrderType.Move;
    }
    
    void clearOrder() {
      nextOrders.clear();
      currentOrder = Order();
    }

    Path[][Coord][2] memoPathes;
    Path[] pathes(Coord from, bool free) {
      if (from in memoPathes[free]) {
        return memoPathes[free][from];
      }

      Path[] ret;
      auto graph = graphs[free ? 0 : 1];
      foreach(d, c; graph[from.r][from.c]) {
        if (c == '.') continue;

        if (d == 0) ret ~= Path(c, Coord(from.r, from.c - 1));
        else if (d == 1) ret ~= Path(c, Coord(from.r - 1, from.c));
        else if (d == 2) ret ~= Path(c, Coord(from.r, from.c + 1));
        else if (d == 3) ret ~= Path(c, Coord(from.r + 1, from.c));
      }
      return memoPathes[free][from] = ret;
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
          if (id > 0 && !free && next.c < N - 1 && grid[next.r][next.c] != -1 && next != to) continue;
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
    Coord[] stockSpaces;

    int[] pulledByRow;
    int[] pushedByRow;
    bool[] pushedByItem;

    int[][] grid;
    Coord[int] coordByItem;

    int turn;
    Crane[] cranes;
    int[][] outputs;
    Path[][] moves;
    
    this(int[][] stocks, int useCrane, Coord[] stockSpaces, string[][][] graphs) {
      this.stockSpaces = stockSpaces;
      baseStocks = stocks.map!"a.dup".array;
      pulledByRow = 1.repeat(N).array;
      pushedByRow = new int[](N);
      pushedByItem = new bool[](N ^^ 2);
      itemStates = (ItemState.Unplaced).repeat(N ^^ 2).array;
      heads = iota(0, N^^2, N).redBlackTree;

      outputs = new int[][](N, 0);
      cranes = N.iota.map!(i => new Crane(i, graphs)).array;
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

      foreach(int c; useCrane..N) {
        cranes[c].destroyed = true;
        moves[c] ~= Path('B');
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
      foreach(c; stockSpaces ~ [Coord(3, 0), Coord(2, 0), Coord(1, 0), Coord(0, 0), Coord(4, 0),]) {
        if (grid[c.r][c.c] == -1) return c;
      }

      return Coord.Invalid;
    }

    void afterProcess() {
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
        if (!crane.free || crane.destroyed) continue;
        if (!(crane.order.type == OrderType.Wait || crane.order.type == OrderType.Move)) continue;

        auto d = crane.route(to, grid).length.to!int;
        if (minDistance.chmin(d)) {
          ret = cranes[i];
        }
      }

      return ret;
    }

    void simulate(int parallel) {
      foreach(_; 0..300) {
        turn++;
        deb("");
        deb("------------------------------------ TURN: ", turn, " --------------------------------------");

        foreach(toPick; nextItems[0..min(parallel, $)]) {
          deb(nextItems, toPick, itemStates[toPick]);
          if (itemStates[toPick] != ItemState.Placed && itemStates[toPick] != ItemState.Moved) toPick = headOfItem(toPick);
          deb(nextItems, toPick);
          if (toPick != -1 && (itemStates[toPick] == ItemState.Placed || itemStates[toPick] == ItemState.Moved)) {
            auto coordToPick = coordByItem[toPick];
            auto crane = waitingNearestCrane(coordToPick);

            if (crane) {
              crane.clearOrder();
              crane.putOrder(Order(OrderType.Pick, coordToPick));
              itemStates[toPick] = ItemState.Waiting;

              if (toPick in heads) {
                crane.putOrder(Order(OrderType.Drop, Coord(toPick / N, N - 1)));
                crane.putOrder(Order(OrderType.Move, Coord(4, 2)));
              } else {
                auto toMove = findEmptyCoord();
                if (toMove == Coord.Invalid) {
                  // throw new Exception("No Space");
                  crane.putOrder(Order(OrderType.Keep, Coord(0, 2)));
                  crane.putOrder(Order(OrderType.Keep, Coord(4, 2)));
                } else {
                  grid[toMove.r][toMove.c] = -2;
                  crane.putOrder(Order(OrderType.Drop, toMove));
                  crane.putOrder(Order(OrderType.Move, Coord(4, 2)));
                }
              }
            }
          }
        }

        foreach(crane; cranes) {
          if (crane.waiting() && crane.coord == Coord(4, 2)) {
            if (!crane.free) {
              auto item = crane.item;
              if (item in heads) {
                crane.clearOrder();
                crane.putOrder(Order(OrderType.Drop, Coord(item / N, N - 1)));
                crane.putOrder(Order(OrderType.Move, Coord(4, 2)));
                continue;
              } else {
                auto toMove = findEmptyCoord();
                if (toMove != Coord.Invalid) {
                  grid[toMove.r][toMove.c] = -2;
                  crane.putOrder(Order(OrderType.Drop, toMove));
                  crane.putOrder(Order(OrderType.Move, Coord(4, 2)));
                  continue;
                }
              }
            }

            crane.putOrder(Order(OrderType.Move, Coord(0, 2)));
            crane.putOrder(Order(OrderType.Move, Coord(4, 4)));
            crane.putOrder(Order(OrderType.Move, Coord(4, 4)));
            crane.putOrder(Order(OrderType.Move, Coord(4, 2)));
          }
        }

        int[Coord] cur, next;
        foreach(i, crane; cranes.enumerate(0)) {
          if (crane.destroyed) continue;

          cur[crane.coord] = i;
          next[crane.coord] = i;
        }
        
        Path[] craneMoves = cranes.map!(c => Path('.', c.coord)).array;
        foreach(i; N.iota) {
        // foreach(i; N.iota.array.sort!((a, b) => cranes[a].item > cranes[b].item)) {
          auto crane = cranes[i];
          if (crane.waiting() || crane.destroyed) continue;

          if (!crane.free && crane.item in heads && crane.coord == Coord(crane.item / N, N - 1)) {
            auto nextOrder = crane.nextOrders.empty ? Order() : crane.nextOrders.front;
            if (nextOrder.type == OrderType.Drop && nextOrder.coord.c != N - 1) {
              auto nxc = nextOrder.coord;
              grid[nxc.r][nxc.c] = -1;
            }
            grid[crane.coord.r][crane.coord.c] = crane.item;
            itemStates[crane.item] = ItemState.Delivered;
            coordByItem[crane.item] = crane.coord;
            crane.item = -1;
            craneMoves[i] = Path('Q', crane.coord);
            crane.clearOrder();
            crane.putOrder(Order(OrderType.Move, Coord(4, 2)));
            continue;
          }

          auto order = crane.order();
          if (crane.coord == order.coord) {
            if (order.type == OrderType.Pick) {
              auto item = grid[crane.coord.r][crane.coord.c];
              grid[crane.coord.r][crane.coord.c] = -1;
              crane.item = item;
              itemStates[item] = ItemState.Picked;
              coordByItem[item] = Coord.Invalid;
              craneMoves[i] = Path('P', crane.coord);
            } else if (order.type == OrderType.Drop) {
              grid[crane.coord.r][crane.coord.c] = crane.item;
              itemStates[crane.item] = crane.coord.c == N - 1 ? ItemState.Delivered : ItemState.Moved;
              coordByItem[crane.item] = crane.coord;
              crane.item = -1;
              craneMoves[i] = Path('Q', crane.coord);
            }
          } else {
            // crane.deb;
            // grid.each!deb;
            auto nextPath = crane.route(crane.order.coord, grid)[0];
            auto from = crane.coord;
            auto to = nextPath.to;
            if (to in next) continue;
            if (cur.get(to, -1) == next.get(from, -2)) continue;
            
            enum LBPickerCoords = [Coord(4, 0)];
            if (from == Coord(4, 2) && LBPickerCoords.any!(c => c in cur)) continue;

            craneMoves[i] = nextPath;
            next.remove(from);
            next[to] = i.to!int;
          }
        }

        foreach(i, m; craneMoves) {
          auto crane = cranes[i];
          moves[i] ~= m;
          crane.coord = m.to;
          
          if (crane.coord == crane.order.coord) {
            if (crane.order.type == OrderType.Pick && !crane.free) crane.currentOrder = Order();
            else if (crane.order.type == OrderType.Drop && crane.free) crane.currentOrder = Order();
            else if (crane.order.type == OrderType.Move) crane.currentOrder = Order();
            else if (crane.order.type == OrderType.Keep) crane.currentOrder = Order();
          }
        }

        cranes.each!deb;
        afterProcess();
        if (pushedByRow.sum == N^^2) break;
      }
    }

    int score() {
      return turn + (N^^2 - pushedByRow.sum)*1000;
    }
  }

  static Coord SpaceA = Coord(1, 2);
  static Coord SpaceB = Coord(1, 3);
  static Coord SpaceC = Coord(2, 2);
  static Coord SpaceD = Coord(2, 3);
  static Coord SpaceE = Coord(3, 2);
  static Coord SpaceF = Coord(3, 3);

  // 積荷を持ってないクレーン用のグラフ
  auto freeCraneGraph = [
    ["..R.", "..R.", "..RD", "..RD", "...D"],
    [".UR.", ".UR.", "..RD", "...D", "...D"],
    [".UR.", ".UR.", "..RD", "...D", "...D"],
    [".UR.", ".UR.", "..RD", "...D", "...D"],
    [".U..", "LU..", "L...", "L...", "L..."],
  ];
  auto freeCraneGraph2 = [
    ["..R.", "..R.", "..RD", "..RD", "...D"],
    [".U..", ".UR.", "..RD", "...D", "...D"],
    [".U..", ".UR.", "..RD", "...D", "...D"],
    [".U..", ".UR.", "..RD", "...D", "...D"],
    [".U..", "LU..", "L...", "L...", "L..."],
  ];
  // 積荷を持っているクレーンのグラフ
  auto workCraneGraph = [
    ["..R.", "L.R.", "..RD", "..RD", "...D"],
    [".UR.", "LUR.", "LUR.", "..R.", "L..D"],
    [".UR.", "LUR.", "L.R.", "..R.", "L..D"],
    [".UR.", "LUR.", "L.R.", "..RD", "L..D"],
    [".UR.", "LU..", "LU..", "L...", "L..."],
  ];

  int bestTurn = int.max;
  State bestState;

  auto SPACE_PATTERNS = [
    [SpaceB, SpaceA, SpaceC, SpaceE, SpaceF, SpaceD],
    [SpaceB, SpaceA, SpaceC, SpaceD, SpaceE, SpaceF],
    [SpaceA, SpaceB, SpaceC, SpaceD, SpaceE, SpaceF],
    [SpaceD, SpaceE, SpaceF, SpaceA, SpaceB, SpaceC],
    [SpaceF, SpaceE, SpaceD, SpaceC, SpaceB, SpaceA],
    [SpaceA, SpaceE, SpaceD, SpaceC, SpaceB, SpaceF],
  ];

  int simulated;
  foreach(spaces; SPACE_PATTERNS) {
    foreach(craneNums; [1, 2, 3, 4, 5]) {
      foreach(parallel; 1..craneNums + 1) {
        foreach(graphs; [[freeCraneGraph, workCraneGraph], [freeCraneGraph2, workCraneGraph]]) {
          State state = State(A, craneNums, spaces.array, graphs);
          state.simulate(parallel);
          simulated++;

          if (bestTurn.chmin(state.score())) {
            bestState = state;
          }
        }
      }
    }
  }

  foreach(spaces; SPACE_PATTERNS[0].permutations.array.randomShuffle(RND)) {
    if (elapsed(2500)) {
      break;
    }

    foreach(craneNums; [1, 2, 3, 4, 5]) {
      foreach(parallel; 1..craneNums + 1) {
        foreach(graphs; [[freeCraneGraph, workCraneGraph], [freeCraneGraph2, workCraneGraph]]) {
          State state = State(A, craneNums, spaces.array, graphs);
          state.simulate(parallel);
          simulated++;

          if (bestTurn.chmin(state.score())) {
            bestState = state;
          }
        }
      }
    }
  }

  stderr.writefln("%s ms / simulation", ((MonoTime.currTime() - StartTime).total!"msecs".to!real / simulated));
  stderr.writefln("Score = %s", bestState.score);

  foreach(move; bestState.moves) {
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
// void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
void deb(T ...)(T t){ debug {  }}
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
