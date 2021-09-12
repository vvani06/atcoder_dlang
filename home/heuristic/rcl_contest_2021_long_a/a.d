void main() { problem(); }

// ----------------------------------------------

class Spawn {
  int x, y, s, e, v;
  bool harvested;

  this(int x, int y, int s, int e, int v) {
    this.x = x;
    this.y = y;
    this.s = s;
    this.e = e;
    this.v = v;
  }

  this(int[] i) {
    this(i[0], i[1], i[2], i[3], i[4]);
  }

  Point point() {
    return Point(x, y);
  }

  override string toString() {
    return "Spawns at (%02s, %02s) in [%04s - %04s] with value %s (harvested: %s)".format(x, y, s, e, v, harvested);
  }
}

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto T = scan!int;
  auto S = M.iota.map!(_ => new Spawn(scan!int(5))).array;

  struct Actor {
    int day;
    int money = 1;
    bool[Point] harvesters;
    Spawn[] spawns;

    this(Spawn[] spawns) {
      this.spawns = spawns;
      this.spawns.multiSort!("a.e < b.e", "a.v > b.v", "a.s < b.s");
    }

    long costForNewHarvester() {
      return (harvesters.length + 1) ^^ 3;
    }

    string buyHarvester(Point at) {
      const cost = costForNewHarvester();
      if (cost > money) throw new Exception("no money to buy a harvester");
      if (at in harvesters) throw new Exception("harvester is already placed");

      money -= cost;
      harvesters[at] = true;
      return "%s %s".format(at.x, at.y);
    }

    string moveHarvester(Point from, Point to) {
      if (!(from in harvesters)) throw new Exception("no harvester");
      if (to in harvesters) throw new Exception("harvester is already placed");

      harvesters.remove(from);
      harvesters[to] = true;
      return "%s %s %s %s".format(from.x, from.y, to.x, to.y);
    }

    string act() {
      auto sp = currentSpawns;
      if (harvesters.length == 0) {
        foreach(s; sp) return buyHarvester(s.point);
      }
      
      foreach(i, s; sp) {
        if (s.point in harvesters) continue;

        foreach(from; harvesters.keys) {
          if (sp[i..$].all!(sps => sps.point != from)) return moveHarvester(from, s.point);
        }

        if (harvesters.length < 5 && money >= costForNewHarvester()) {
          
        }
      }

      return "-1";
    }

    void progressOneDay() {
      day++;
      act().writeln;

      foreach(s; currentSpawns) {
        if (s.point in harvesters) {
          money += s.v;
          s.harvested = true;
        }
      }
      // deb("last money: ", money);
    }

    int simStartIndex;
    Spawn[] currentSpawns() {
      Spawn[] ret;
      int cont;

      foreach(i, s; spawns[simStartIndex..$]) {
        if (s.s > day) break;
        if (s.e < day) {
          simStartIndex++;
          continue;
        }
        if (s.harvested) {
          if (i == cont) {
            cont++;
            simStartIndex++;
          }
          continue;
        }
        ret ~= s;
      }

      return ret;
    }
  }

  auto solve() {
    auto actor = Actor(S);
    foreach(t; 0..T) {
      actor.progressOneDay();
    }
    [actor.money].deb;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop;
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
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
void runSolver() {
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(true) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
