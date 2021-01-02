void main() {
  problem();
}

void problem() {
  auto S = scan;
  auto T = scan;

  long calcMax() {
    Point p;
    long q;

    foreach(c; S) {
      if (c == '?') q++;
      p.move(c);
    }

    return p.distance + q;
  }

  long calcMin() {
    Point p;
    long q;

    foreach(c; S) {
      if (c == '?') q++;
      p.move(c);
    }

    long ans = p.distance - q;
    if (ans < 0) {
      ans = ans % 2 == 0 ? 0 : 1;
    }

    return ans;
  }

  void solve() {
    writeln(T == "1" ? calcMax() : calcMin());
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
void move(ref Point p, char c) {
  if (c == 'L') p.x--;
  if (c == 'R') p.x++;
  if (c == 'D') p.y--;
  if (c == 'U') p.y++;
}
long distance(Point p) { return p.x.abs + p.y.abs; }

// -----------------------------------------------
