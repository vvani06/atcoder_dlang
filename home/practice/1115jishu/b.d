void main() {
  problem();
}

void problem() {
  auto T = scan!long;
  auto S = scan!string(T);

  void solve() {
    enum BASE = "atcoder";
    foreach(s; S) {
      const size = min(s.length, BASE.length);
      long ans;
      long same;
      foreach(i; 0..size) {
        if (s[i] > BASE[i])  {
          writeln(ans);
          break;
        }
        if ()
        if (i == size - 1) {
          foreach(o; 1..size) {
            if (s[o] > BASE[o-1]) 
          }
          writeln(-1);
        }
      }
    }
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

// -----------------------------------------------
