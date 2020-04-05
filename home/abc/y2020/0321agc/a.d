
alias Point = Tuple!(int, "x", int, "y");

void main() {
  auto H = scan!int, W = scan!int;
  bool[][] table = H.iota.map!(_ => scan.map!(c => c == '.').array).array;
  bool at(Point p){ return table[p.y][p.x]; }

  int solve() {

    alias DP = Tuple!(int, "count", bool, "isGood");

    DP[Point] dp;
    Point[] points = [Point(0, 0)];
    dp[points[0]] = DP(at(points[0]) ? 0 : 1, true);

    while(points.length > 0) {
      Point[] next;
      foreach(p; points) {
        if (p.x < W-1) {
          auto right = Point(p.x + 1, p.y);
          auto count = dp[p].count;
          if (at(p) && !at(right)) count++;
          if (!(right in dp) || (right in dp).count > count) {
            dp[right] = DP(count, at(right));
            next ~= right;
          }
        }
        if (p.y < H-1) {
          auto down = Point(p.x, p.y + 1);
          auto count = dp[p].count;
          if (at(p) && !at(down)) count++;
          if (!(down in dp) || (down in dp).count > count) {
            dp[down] = DP(count, at(down));
            next ~= down;
          }
        }
      }

      points = next;
    }
    
    return dp[Point(W-1, H-1)].count;
  }

  solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }

// -----------------------------------------------
