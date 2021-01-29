void main() {
  problem();
}

void problem() {
  auto S = Point(scan!long, scan!long);
  auto E = Point(scan!long, scan!long);

  long solve() {
    long d = (E.x - S.x).abs + (E.y - S.y).abs;
    if (d == 0) {
      return 0;
    }

    if (d <= 3) {
      return 1;
    }
    if (S.x + S.y == E.x + E.y || (S.x - S.y == E.x - E.y)) {
      return 1;
    }

    if (d <= 6) {
      return 2;
    }

    foreach(long dx; -3..4) {
      foreach(long dy; -3..4) {
        if (dx.abs + dy.abs > 3) continue;
        
        const t = Point(S.x + dx, S.y + dy);
        if (t.x + t.y == E.x + E.y || (t.x - t.y == E.x - E.y)) {
          return 2;
        }
      }
    }

    if ((S.x + S.y) % 2 == (E.x + E.y) % 2) {
      return 2;
    } else {
      return 3;
    }
  }

  solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
