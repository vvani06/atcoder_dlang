void main() { problem(); }

// ----------------------------------------------

enum int SIZE = 30;

struct Point {
  int x, y;

  Point add(Point other) { return Point(x + other.x, y + other.y); }
  Point sub(Point other) { return Point(x - other.x, y - other.y); }
  int distance(Point other) { return (x - other.x).abs + (y - other.y).abs; }
  T of(T)(T[SIZE][SIZE] arr) { return arr[y][x]; }
  bool isValid() { return x >= 0 && SIZE > x && y >= 0 && SIZE > y; }

  string toString() {
    return "(%02d %02d)".format(x, y);
  }
}

enum Point[dchar] MOVE = [
  'L': Point(0, -1),
  'R': Point(0, 1),
  'U': Point(-1, 0),
  'D': Point(1, 0),
];
enum dchar[Point] MOVE_INV = [
  Point(0, -1): 'L',
  Point(0, 1): 'R',
  Point(-1, 0): 'U',
  Point(1, 0): 'D',
];

class Animal {
  static int gid;

  enum Type {
    COW = 1,
    PIG = 2,
    RABBIT = 3,
    DOG = 4,
    CAT = 5
  }

  int id;
  Point point;
  Type type; 

  this() {
    id = gid++;
    point = Point(scan!int - 1, scan!int - 1);
    type = cast(Type)scan!int;
  }

  override string toString() {
    return "Pet[%s:%s] (%s, %s)".format(id, type, point.x, point.y);
  }

  void update() {
    scan.each!(c => point = point.add(MOVE[c]));
  }
}

class Human {
  static Game game;
  static int gid;
  int id;
  Point point;

  this() {
    id = gid++;
    point = Point(scan!int - 1, scan!int - 1);
  }

  override string toString() {
    return "Human[%s] (%s, %s)".format(id, point.x, point.y);
  }

  int strategy;
  Point target;
  dchar action;

  void buildWall() {
    action = action.init;

    if (strategy != 1) return;

    if (target.distance(point) == 1) {
      if (target.of(game.noWalls)) action = '.';
      else {
        foreach(dir, move; MOVE) {
          if (point.add(move) == target) {
            action = dir + 'a' - 'A';
            game.walls[target.y][target.x] = true;
            strategy = -1;
            break;
          }
        }
      }
    }
  }

  dchar act() {
    if (action != action.init) return action;

    if (strategy == -1) foreach(dir; MOVE.keys.randomShuffle) {
      auto moved = point.add(MOVE[dir]);
      moved.deb;
      if (moved.isValid() && !moved.of(game.walls)) {
        point = moved;
        return dir;
      }
    }

    if (target != point && !target.of(game.walls)) {
      Point[SIZE][SIZE] grid;
      bool[SIZE][SIZE] visited = game.walls.dup;
      // foreach(ref g; grid) grid[] = Point(-1, -1);

      for(auto q = new DList!Point(point); !q.empty;) {
        auto p = q.front; q.removeFront;
        if (p == target) break;
        if (p.of(visited)) continue;

        visited[p.y][p.x] = true;
        foreach(move; MOVE.values.randomShuffle) {
          auto moved = p.add(move);
          if (moved.isValid && !moved.of(visited)) {
            grid[moved.y][moved.x] = p;
            q.insertBack(moved);
          }
        }
      }

      auto route = target;
      while(route.of(grid) != point) route = route.of(grid);
      auto move = route.sub(point);
      point = route;
      return MOVE_INV[move];
    }

    return '.';
  }
}

class Strategy {
  static Game game;

  bool isFinished() { return true; }
  void simulate() {}
}

class Gather : Strategy {
  Point at;
  this(Point p) {
    at = p;
  }

  override bool isFinished() {
    return game.humen.all!(human => human.point == at);
  }

  override void simulate() {
    foreach(human; game.humen) {
      human.target = at;
      human.strategy = 0;
    }
  }
}

class Wait : Strategy {
  int turns;
  this(int turns) { this.turns = turns; }

  override bool isFinished() { return turns <= 0; }
  override void simulate() { turns--; }
}

class CreateWalls : Strategy {
  bool[Point] at;
  Point[Human] queued;

  this(Point[] p) {
    p.filter!(a => !a.of(game.walls)).each!(a => at[a] = true);
  }

  override bool isFinished() {
    foreach(human, point; queued) {
      if (point.of(game.walls)) queued.remove(human);
    }
    return at.empty && queued.empty;
  }

  override void simulate() {
    if (at.empty) return;

    foreach(human; game.humen) {
      if (at.empty) return;
      if (human in queued) continue;

      int minDist = int.max;
      Point target;
      foreach(p; at.keys) {
        auto dist = p.distance(human.point);
        if (dist == 0) continue;

        if (minDist.chmin(dist)) {
          target = p;
        }
      }

      human.strategy = 1;
      human.target = target;
      at.remove(target);
      queued[human] = target;
    }
  }
}


class Game {
  bool[SIZE][SIZE] walls;
  bool[SIZE][SIZE] noWalls;
  int turn;

  Animal[] animals;
  Human[] humen;
  DList!Strategy strategies;

  this() {
    Human.game = this;
    Strategy.game = this;
    scan!int.iota.each!(_ => animals ~= new Animal());
    scan!int.iota.each!(_ => humen ~= new Human());

    if (animals.any!(a => a.type == Animal.Type.DOG)) {
      const dogWalk = 25;
      strategies ~= new CreateWalls(
        dogWalk.iota.map!(y => Point(3, y)).array ~
        Point(2,dogWalk) ~ Point(1,dogWalk) ~
        Point(2,dogWalk - 4) ~ Point(1,dogWalk - 4) ~
        Point(0,dogWalk - 2) ~ Point(1,dogWalk - 2)
      );
      strategies ~= new Gather(Point(2, 0));
      strategies ~= new Gather(Point(0, dogWalk));
      strategies ~= new CreateWalls([Point(0, dogWalk - 1)]);
    }

    strategies[].deb;
  }

  void initTurn() {
    noWalls = walls.dup;
    foreach(human; humen) noWalls[human.point.y][human.point.x] = true;
    foreach(animal; animals) {
      noWalls[animal.point.y][animal.point.x] = true;
      foreach(move; MOVE.values) {
        auto p = animal.point.add(move);
        if (p.isValid) noWalls[p.y][p.x] = true;
      }
    }
  }

  void humenTurn() {
    humen.each!"a.buildWall";
    humen.map!"a.act".array.writeln;
    stdout.flush();
  }

  void animalsTurn() {
    animals.each!"a.update";
  }

  void run() {
    foreach(ref human; humen) human.target.x = 1;
    foreach(t; 0..300) {
      while (!strategies.empty && strategies.front.isFinished) strategies.removeFront;
      if (!strategies.empty) {
        auto strategy = strategies.front;
        strategy.deb;
        strategy.simulate();
      }

      initTurn();
      humenTurn();
      animalsTurn();
    }
  }
}

void problem() {
  (new Game()).run();
}

// ----------------------------------------------

import std;
import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
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
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
