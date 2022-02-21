void main() { problem(); }

// ----------------------------------------------

void problem() {
  enum int G = 30;
  auto N = scan!int;
  auto P = scan!int(3 * N).chunks(3).array;
  auto M = scan!int;
  auto H = scan!int(2 * M).chunks(2).array;
  int[31][31] gp;
  int[31][31] gh;
  bool[31][31] proh;

  class Pet {
    int id, x, y, type;
    this(int id, int x, int y, int type) {
      this.id = id;
      this.x = x;
      this.y = y;
      this.type = type;
      gp[y][x]++;
    }

    override string toString() {
      return "Pet[%s:%s] (%s, %s)".format(id, type, x, y);
    }
  }

  class Human {
    int id, x, y;
    int gx, gy;
    this(int id, int x, int y) {
      this.id = id;
      this.x = x;
      this.y = y;
      gx = 1;
      gy = max(5, y - y%5);
      gh[y][x]++;
    }
    override string toString() {
      return "Human[%s] (%s, %s)".format(id, x, y);
    }

    dchar move(int turn) {
      gh[y][x]--;

      dchar moveInner() {
        if (x == gx) gx = gx == 1 ? 30 : 1;

        if (y > gy) return 'L';
        if (y < gy) return 'R';

        if (turn < 8) return '.';
        
        const by = y - 1;
        if (!proh[by][x]) {
          if (gh[by][x] > 0) return '.';
          if (gp[by][x] > 0) return '.';
          foreach(xy; [[-1, 0], [0, -1], [1, 0], [0, 1]]) {
            const ax = x + xy[0];
            const ay = by + xy[1];
            if (ax <= 0 || ay <= 0 || ax > G || ay > G) continue;

            if (gp[ay][ax] > 0) return '.';
          }

          proh[by][x] = true;
          return 'l';
        }

        if (x > gx) return 'U';
        if (x < gx) return 'D';
        return '.';
      }
      auto ret = moveInner();
      if (ret == 'L') y--;
      if (ret == 'R') y++;
      if (ret == 'U') x--;
      if (ret == 'D') x++;

      gh[y][x]++;
      return ret;
    }
  }

  auto solve() {
    auto pets = N.iota.map!(i => new Pet(i, P[i][0], P[i][1], P[i][2])).array;
    auto humen = M.iota.map!(i => new Human(i, H[i][0], H[i][1])).array;

    foreach(t; 0..300) {
      // "turn: %s".format(t).deb;
      humen.map!(h => h.move(t)).array.writeln;
      
      stdout.flush();
      foreach(ref p; pets) {
        gp[p.y][p.x]--;
        auto order = scan;
        foreach(m; order) {
          if (m == 'U') p.x--;
          if (m == 'L') p.y--;
          if (m == 'D') p.x++;
          if (m == 'R') p.y++;
        }
        // p.deb;
        gp[p.y][p.x]++;
      }
    }
  }

  solve();
}

// ----------------------------------------------

import std;
import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
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

alias Point = Tuple!(long, "x", long, "y");
long distance(Point a, Point b) {
  return ((a.x - b.x)^^2 + (a.y - b.y)^^2).to!real.sqrt.to!long;
}

// -----------------------------------------------
