void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  int N = scan!int;
  int M = scan!int;
  int K = scan!int;
  int T = scan!int;

  struct Card {
    int type;
    long work, cost;
    int level;
    bool used;

    this(long[] inputs, int level = 0) {
      type = inputs[0].to!int;
      work = inputs[1];
      if (inputs.length > 2) cost = inputs[2];
      this.level = level;
    }

    float leveledCost() {
      return max(0.1, cost.to!float / 2^^level);
    }

    bool toWork() { return [0, 1].canFind(type); }
    bool toStop() { return [2, 3].canFind(type); }
    bool toIncrement() { return [4].canFind(type); }

    float performance() {
      switch (type) {
        case 0:
          return cost == 0 ? work : work.to!float / cost;
        case 1:
          return cost == 0 ? work : work.to!float / M / cost;
        case 2, 3:
          return 4.0 / leveledCost;
        case 4:
          return 600.0 / leveledCost;
        default:
          return 0;
      }
    }
  }

  struct Project {
    long work, value;
    this(long[] inputs) {
      work = inputs[0];
      value = inputs[1];
    }

    float performance() {
      return value.to!float / work;
    }
  }

  class Game {
    int turn, level;
    long money;
    Card[] cards;
    Project[] projects;

    this(long[][] initialCards, long[][] initialProjects) {
      cards = initialCards.map!(c => Card(c)).array;
      projects = initialProjects.map!(p => Project(p)).array;
    }

    int bestProject() {
      return projects.map!"a.performance".maxIndex.to!int;
    }
    int worstProject() {
      return projects.map!"a.performance".minIndex.to!int;
    }

    int bestProjectFor(Card card) {
      if ([1, 3, 4].canFind(card.type)) return 0;

      if (card.type == 0) {
        int toBeDone = -1;
        foreach(i, p; projects.enumerate(0)) {
          if (p.work <= card.work * 1.2) {
            if (toBeDone == -1 || projects[toBeDone].value < p.value) toBeDone = i;
          }
        }
        return toBeDone != -1 ? toBeDone : bestProject();
      }

      return worstProject();
    }

    int[] choice() {
      if (hasIncrementCard()) {
        level++;
        return [cards.maxIndex!"a.type < b.type".to!int, 0];
      }

      if (projects[bestProject()].performance < 1.1 && hasStopCard()) {
        auto ci = cards.maxIndex!"a.type < b.type".to!int;
        return [ci, cards[ci].type == 2 ? worstProject() : 0];
      }

      if (hasAllWorkCard()) {
        auto ci = cards.countUntil!"a.type == 1".to!int;
        return [ci, 0];
      }

      int chosen = cards.minIndex!"a.type < b.type".to!int;
      foreach(i, card; cards.enumerate(0)) {
        if (cards[chosen].type == 0 && card.type == 0) {
          if (cards[chosen].work < card.work) {
            chosen = i;
          }
        }
      }
      return [chosen, bestProjectFor(cards[chosen])];
    }


    bool hasAllWorkCard() {
      return cards.filter!"!a.used".any!"a.type == 1";
    }
    
    bool hasStopCard() {
      return cards.filter!"!a.used".any!"a.toStop";
    }

    bool hasIncrementCard() {
      return cards.filter!"!a.used".any!"a.toIncrement";
    }

    int draw(Card[] candidates) {
      int toDraw = 0;
      foreach(i, card; candidates[1..$].enumerate(1)) {
        if (money < card.cost) continue;

        if (turn <= 800 && card.type == 4 && card.performance() >= 1.0) {
          toDraw = i;
          break;
        }

        if (!hasStopCard() && card.toStop() && card.performance() > 2.5) {
          toDraw = i;
        }

        if (card.toWork() && card.performance() > 1.6) {
          toDraw = i;
        }
      }

      foreach(i; 0..N) {
        if (cards[i].used) {
          cards[i] = candidates[toDraw];
          break;
        }
      }
      return toDraw;
    }
  }

  long[][] IN_CARDS = scan!long(2 * N).chunks(2).array;
  long[][] IN_PROJECTS = scan!long(2 * M).chunks(2).array;

  auto solve() {
    auto game = new Game(IN_CARDS, IN_PROJECTS);

    foreach(turn; 0..T) {
      game.turn = turn;

      auto chosen = game.choice();
      game.cards[chosen[0]].used = true;
      writefln("%(%s %)", chosen); stdout.flush();

      game.projects = scan!long(2 * M).chunks(2).map!(p => Project(p)).array;
      game.money = scan!long;

      auto cards = scan!long(3 * K).chunks(3).map!(c => Card(c, game.level)).array;
      game.draw(cards).writeln; stdout.flush();
    }
  }

  solve();
}

// ----------------------------------------------

import std;
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
