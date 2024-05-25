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
    byte r, c;

    static Coord Invalid = Coord(-1, -1);
  }

  byte index(Coord coord) {
    return cast(byte)(coord.r * N + coord.c);
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

  // 積荷退避用のスペース
  enum Coord SpaceA = Coord(1, 2);
  enum Coord SpaceB = Coord(1, 3);
  enum Coord SpaceC = Coord(2, 2);
  enum Coord SpaceD = Coord(2, 3);
  enum Coord SpaceE = Coord(3, 2);
  enum Coord SpaceF = Coord(3, 3);
  enum SPACE_PATTERNS = [
    [SpaceB, SpaceA, SpaceC, SpaceE, SpaceF, SpaceD],
    [SpaceB, SpaceA, SpaceC, SpaceD, SpaceE, SpaceF],
    [SpaceA, SpaceB, SpaceC, SpaceD, SpaceE, SpaceF],
    [SpaceD, SpaceE, SpaceF, SpaceA, SpaceB, SpaceC],
    [SpaceF, SpaceE, SpaceD, SpaceC, SpaceB, SpaceA],
    [SpaceA, SpaceE, SpaceD, SpaceC, SpaceB, SpaceF],
  ];
  enum SPACES = [
    SpaceA, SpaceB,
    SpaceC, SpaceD,
    SpaceE, SpaceF,
    Coord(0, 0), Coord(1, 0), Coord(2, 0), Coord(3, 0), Coord(4, 0),
  ];
  auto ALL_PATTERNS = SPACE_PATTERNS[0].permutations.map!"a.array".array;
  auto SPACE_INDEX = SPACES.enumerate(0).map!reverse.assocArray;

  // 積荷を持ってないクレーン用のグラフ
  auto FREE_GRAPH = [
    ["..R.", "..R.", "..RD", "..RD", "...D"],
    [".UR.", ".UR.", "..RD", "...D", "...D"],
    [".UR.", ".UR.", "..RD", "...D", "...D"],
    [".UR.", ".UR.", "..RD", "...D", "...D"],
    [".U..", "LU..", "L...", "L...", "L..."],
  ];
  // 積荷を持っているクレーンのグラフ
  auto WORK_GRAPH = [
    ["..R.", "L.R.", "..RD", "..RD", "...D"],
    [".UR.", "LUR.", "LURD", "..RD", "L..D"],
    [".UR.", "LUR.", "L.RD", "..RD", "L..D"],
    [".UR.", "LUR.", "L.R.", "L.RD", "L..D"],
    [".UR.", "LU..", "LU..", "L...", "L..."],
  ];

  auto GRAPH_PATTERNS = [
    FREE_GRAPH,
    WORK_GRAPH,
  ];

  Path[][25] CALC_ALL_PATHES(string[][] graph) {
    Path[][25] ret;
    foreach(byte fr; 0..5) foreach(byte fc; 0..5) {
      Path[] perGrid;
      foreach(d, c; graph[fr][fc]) {
        if (c == '.') continue;

        if (d == 0) perGrid ~= Path(c, Coord(fr, cast(byte)(fc - 1)));
        else if (d == 1) perGrid ~= Path(c, Coord(cast(byte)(fr - 1), fc));
        else if (d == 2) perGrid ~= Path(c, Coord(fr, cast(byte)(fc + 1)));
        else if (d == 3) perGrid ~= Path(c, Coord(cast(byte)(fr + 1), fc));
      }
      ret[fr * 5 + fc] ~= perGrid;
    }
    return ret;
  }
  auto GRAPH_PATH = GRAPH_PATTERNS.map!(g => CALC_ALL_PATHES(g)).array;

  auto ROUTES = new Path[][25][25][2^^SPACES.length][GRAPH_PATTERNS.length];
  foreach(graphId, graph; GRAPH_PATTERNS) {
    foreach(bits; 0..2^^SPACES.length) {
      Path[][25] searchAllRoute(Coord from) {
        bool[25] routed;
        routed[from.r * N + from.c] = true;
        Path[][25] froms;

        for(auto queue = DList!Coord(from); !queue.empty;) {
          auto cur = queue.front;
          queue.removeFront;

          foreach(path; GRAPH_PATH[graphId][cur.r * 5 + cur.c]) {
            auto next = path.to;
            if (next in SPACE_INDEX && ((bits & 2^^SPACE_INDEX[next]) != 0)) continue;
            if (routed[next.r * N + next.c]) continue;
            
            routed[next.r * N + next.c] = true;
            froms[next.r * N + next.c] = froms[cur.r * N + cur.c].dup ~ path;
            queue.insertBack(next);
          }
        }
        
        return froms;
      }

      foreach(byte fr; 0..5) foreach(byte fc; 0..5) {
        ROUTES[graphId][bits][fr * N + fc] = searchAllRoute(Coord(fr, fc));
      }
    }
  }

  class Crane {
    int id;
    int[] graphIds;

    int item;
    Coord coord;
    Order currentOrder;
    DList!Order nextOrders;
    bool destroyed;

    this(int id, int[] graphIds) {
      this.id = id;
      item = -1;
      coord = Coord(cast(byte)id, 0);
      currentOrder = Order();
      this.graphIds = graphIds;
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

    ref Path[] pathes(Coord from, bool free) {
      return GRAPH_PATH[graphIds[free]][from.r * 5 + from.c];
    }

    ref Path[] memoizedRoute(Coord to, int bnState, int forceState = -1) {
      auto from = coord;
      auto f = forceState == -1 ? free : forceState;
      auto graphId = graphIds[f];
      auto s = f || id == 0 ? 0 : bnState;
      return ROUTES[graphId][s][from.r * N + from.c][to.r * N + to.c];
    }

    ref Path[] memoizedDropFromTo(Coord from, Coord to, int bnState, int forceState = -1) {
      auto f = forceState == -1 ? free : forceState;
      auto graphId = graphIds[f];
      auto s = f || id == 0 ? 0 : bnState;
      return ROUTES[graphId][s][from.r * N + from.c][to.r * N + to.c];
    }
    
    // Path[] route(Coord to, ref int[][] grid) {
    //   auto from = coord;
    //   Path[][] froms = new Path[][](N, N);
    //   froms[from.r][from.c].move = 1;

    //   for(auto queue = DList!Coord(from); !queue.empty;) {
    //     auto cur = queue.front;
    //     queue.removeFront;

    //     foreach(path; pathes(cur, free)) {
    //       auto next = path.to;
    //       if (id > 0 && !free && next.c < N - 1 && grid[next.r][next.c] != -1 && next != to) continue;
    //       if (froms[next.r][next.c].move != char.init) continue;

    //       froms[next.r][next.c] = Path(path.move, cur);
    //       if (next == to) break;
    //       queue.insertBack(next);
    //     }
    //   }

    //   Path[] ret;
    //   while(to != from) {
    //     auto path = froms[to.r][to.c];
    //     if (path.move == char.init) throw new Exception("Illegal Move");
    //     ret ~= Path(path.move, to);
    //     to = path.to;
    //   }
    //   return ret.reverse.array;
    // }

    int itemPriority() {
      return item == -1 ? -1 : N - item % N;
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
    RedBlackTree!int heads, waitingDelivereds;
    Coord[] stockSpaces;
    int greediness;

    int[] pulledByRow;
    int[] pushedByRow;
    bool[] pushedByItem;

    int[][] grid;
    int bnState;
    Coord[] coordByItem;

    int turn;
    Crane[] cranes;
    int[][] outputs;
    Path[][] moves;
    
    this(int[][] stocks, int useCrane, Coord[] stockSpaces, int[] graphIds, int greediness) {
      this.stockSpaces = stockSpaces;
      this.greediness = greediness;
      baseStocks = stocks.map!"a.dup".array;
      pulledByRow = 1.repeat(N).array;
      pushedByRow = new int[](N);
      pushedByItem = new bool[](N ^^ 2);
      itemStates = (ItemState.Unplaced).repeat(N ^^ 2).array;
      heads = iota(0, N^^2, N).redBlackTree;
      waitingDelivereds = iota(0, N^^2, N).redBlackTree;

      outputs = new int[][](N, 0);
      cranes = N.iota.map!(i => new Crane(i, graphIds)).array;
      moves = N.iota.map!(i => [Path(0, Coord(cast(byte)i, 0))]).array;
      coordByItem = Coord.Invalid.repeat(N^^2).array;

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
        coordByItem[item] = Coord(cast(byte)r, 0);
        itemStates[item] = ItemState.Placed;
        bnState ^= 2^^SPACE_INDEX[Coord(cast(byte)r, 0)];
      }

      foreach(int c; useCrane..N) {
        cranes[c].destroyed = true;
        moves[c] ~= Path('B');
      }
    }

    void pickItem(Crane crane) {
      auto item = grid[crane.coord.r][crane.coord.c];
      grid[crane.coord.r][crane.coord.c] = -1;
      crane.item = item;
      itemStates[item] = ItemState.Picked;
      coordByItem[item] = Coord.Invalid;
      // craneMoves[i] = Path('P', crane.coord);
      bnState ^= 2^^SPACE_INDEX[crane.coord];
    }

    void dropItem(Crane crane) {
      grid[crane.coord.r][crane.coord.c] = crane.item;
      itemStates[crane.item] = crane.coord.c == N - 1 ? ItemState.Delivered : ItemState.Moved;
      coordByItem[crane.item] = crane.coord;
      crane.item = -1;
      // craneMoves[i] = Path('Q', crane.coord);
      if (crane.coord.c < N - 1) bnState ^= 2^^SPACE_INDEX[crane.coord];
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
    
    bool isCoordEmpty(byte r, byte c) { return isCoordEmpty(Coord(r, c)); }
    bool isCoordEmpty(Coord coord) {
      if (grid[coord.r][coord.c] != -1) return false;
      // if (cranes.any!(t => t.coord == coord)) return false;

      return true;
    }

    Coord findEmptyCoord() {
      foreach(c; stockSpaces ~ [Coord(0, 0), Coord(1, 0), Coord(2, 0), Coord(3, 0), Coord(4, 0),]) {
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
        coordByItem[item] = Coord.Invalid;
        grid[r][N - 1] = -1;
        pushedByRow[r]++;

        heads.removeKey(item);
        waitingDelivereds.removeKey(item);
        pushedByItem[item] = true;
        if (item % N != N - 1) {
          heads.insert(item + 1);
          waitingDelivereds.insert(item + 1);
        }
      }

      // 搬入口からの補充
      foreach(byte r; 0..cast(byte)N) {
        if (this.stocks[r].empty || !isCoordEmpty(cast(byte)r, 0)) continue;

        auto item = this.stocks[r].front;
        grid[r][0] = item;
        coordByItem[item] = Coord(r, 0);
        bnState ^= 2^^SPACE_INDEX[Coord(r, 0)];
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

        auto d = crane.memoizedRoute(to, bnState).length.to!int;
        if (minDistance.chmin(d)) {
          ret = cranes[i];
        }
      }

      return ret;
    }

    bool orderPickItem(int item) {
      if (item == -1 || !(itemStates[item] == ItemState.Placed || itemStates[item] == ItemState.Moved)) return false;

      auto coordToPick = coordByItem[item];
      auto crane = waitingNearestCrane(coordToPick);
      if (!crane) return false;

      crane.clearOrder();
      crane.putOrder(Order(OrderType.Pick, coordToPick));
      itemStates[item] = ItemState.Waiting;

      if (item in heads) {
        crane.putOrder(Order(OrderType.Drop, Coord(cast(byte)(item / N), cast(byte)(N - 1))));
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
      return true;
    }

    void simulate(int parallel) {
      foreach(_; 0..200) {
        turn++;
        deb("");
        deb("------------------------------------ TURN: ", turn, " --------------------------------------");

        // 納品間近であれば、次のアイテムを Target にする
        // 間近であるかどうかは納品までの距離と次アイテムを拾う最短クレーンの距離で判断する
        foreach(crane; cranes) {
          if (!(crane.item in heads) || crane.item % N == N - 1) continue;

          auto toDrop = Coord(cast(byte)(crane.item / N), cast(byte)(N - 1));
          auto toDropDist = crane.memoizedRoute(toDrop, bnState).length;

          auto toPick = crane.item + 1;
          if (itemStates[toPick] != ItemState.Placed && itemStates[toPick] != ItemState.Moved) toPick = headOfItem(toPick);
          if (toPick == -1) continue;

          auto nextCoord = coordByItem[toPick];
          if (nextCoord == Coord.Invalid) nextCoord = Coord(cast(byte)(stockedRowByItem[toPick]), 0);
          auto nearest = waitingNearestCrane(nextCoord);
          if (!nearest) continue;

          auto pickDist = nearest.memoizedRoute(nextCoord, bnState).length;
          auto dropDist = nearest.memoizedDropFromTo(nextCoord, Coord(cast(byte)(toPick % N), cast(byte)(N - 1)), bnState, 0).length;
          if (pickDist + dropDist >= toDropDist) {
            auto item = crane.item;
            heads.removeKey(crane.item);
            heads.insert(crane.item + 1);
          }
        }

        foreach(toPick; nextItems[0..min(parallel, $)]) {
          deb(nextItems, toPick, itemStates[toPick]);
          if (itemStates[toPick] != ItemState.Placed && itemStates[toPick] != ItemState.Moved) toPick = headOfItem(toPick);
          deb(nextItems, toPick);
          orderPickItem(toPick);
        }

        foreach(crane; cranes) {
          // 暇で一周してきたクレーンにオーダーをだす
          if (crane.waiting() && crane.coord == Coord(4, 2)) {
            if (!crane.free) {
              auto item = crane.item;
              if (item in waitingDelivereds) {
                crane.clearOrder();
                crane.putOrder(Order(OrderType.Drop, Coord(cast(byte)(item / N), cast(byte)(N - 1))));
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

            // オーダーがないならもう一周まわってもらう
            crane.putOrder(Order(OrderType.Move, Coord(0, 2)));
            crane.putOrder(Order(OrderType.Move, Coord(4, 4)));
            crane.putOrder(Order(OrderType.Move, Coord(4, 2)));
          }
        }

        byte[25] cx, nx;
        cx[] = -1;
        nx[] = -2;
        foreach(i, crane; cranes.enumerate(cast(byte)0)) {
          if (crane.destroyed) continue;

          cx[index(crane.coord)] = i;
          nx[index(crane.coord)] = i;
        }

        // void simulateMove(Crane crane)
        
        Path[] craneMoves = cranes.map!(c => Path('.', c.coord)).array;
        foreach(i; N.iota) {
        // foreach(i; N.iota.array.sort!((a, b) => cranes[a].itemPriority > cranes[b].itemPriority)) {
          auto crane = cranes[i];
          if (crane.waiting() || crane.destroyed) continue;

          // 納品可能なクレーンの優先的な処理
          if (!crane.free && crane.item in waitingDelivereds) {
            auto toDrop = Coord(cast(byte)(crane.item / N), cast(byte)(N - 1));
            auto toDropDist = crane.memoizedRoute(toDrop, bnState).length;

            // 納品実施
            if (toDropDist == 0) {
              auto nextOrder = crane.nextOrders.empty ? Order() : crane.nextOrders.front;
              if (nextOrder.type == OrderType.Drop && nextOrder.coord.c != N - 1) {
                auto nxc = nextOrder.coord;
                grid[nxc.r][nxc.c] = -1;
              }
              dropItem(crane);
              craneMoves[i] = Path('Q', crane.coord);
              crane.clearOrder();
              crane.putOrder(Order(OrderType.Move, Coord(4, 2)));
              continue;
            }
          }

          auto order = crane.order();
          if (crane.coord == order.coord) {
            if (order.type == OrderType.Pick) {
              pickItem(crane);
              craneMoves[i] = Path('P', crane.coord);
            } else if (order.type == OrderType.Drop) {
              dropItem(crane);
              craneMoves[i] = Path('Q', crane.coord);
            }
          } else {
            // stdout.writefln("%s %s %s", crane, crane.order.coord, bnState);
            auto nextPath = crane.memoizedRoute(crane.order.coord, bnState)[0];
            auto from = crane.coord;
            auto to = nextPath.to;
            if (nx[index(to)] >= 0) continue;
            if (cx[index(to)] == nx[index(from)]) continue;
            
            enum LBPickerCoords = [Coord(4, 0)];
            if (from == Coord(4, 2) && LBPickerCoords.any!(c => cx[index(c)] >= 0)) continue;

            craneMoves[i] = nextPath;
            nx[index(from)] = -2;
            nx[index(to)] = i.to!byte;
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

        // cranes.each!deb;
        afterProcess();
        if (pushedByRow.sum == N^^2) break;
      }
    }

    int score() {
      int ret = turn;
      ret += (N^^2 - pushedByRow.sum) * 10^^6;
      foreach(r; 0..N) foreach(i, a; outputs[r]) {
        ret += 10^^2 * outputs[r][0..i].count!(x => x > a);
      }
      return ret;
    }
  }

  int bestTurn = int.max;
  int simulated;
  State bestState;

  auto RANDOM_PATTERNS = ALL_PATTERNS.randomShuffle(RND).array;
  MAIN: foreach(spaces; SPACE_PATTERNS ~ RANDOM_PATTERNS) {

    foreach(greediness; [4]) 
    foreach(craneNums; [5]) 
    foreach(parallel; 3..craneNums + 1)
    foreach(graphs; [[1, 0]]) {
      if (elapsed(2800)) {
        break;
      }

      State state = State(A, craneNums, spaces, graphs, greediness);
      state.simulate(parallel);
      simulated++;

      if (bestTurn.chmin(state.score())) {
        bestState = state;
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
