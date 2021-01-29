void main() {
  auto ans = generate();

  ans.length.writeln;
  ans.joiner("\n").array.writeln;

  debug evaluate(ans).writeln;
}

string[] generate() {
  string[] ans;

  ans ~= "qazzaq";
  ans ~= "wsxujm";
  ans ~= "edccde";
  ans ~= "rfvikl";
  ans ~= "tgbbtt";
  ans ~= "yhnoho";

  return ans;
}

bool evaluate(const string[] grid) {
  const N = grid.length;
  string[] all;
  foreach(i; 0..N) {
    foreach(j; 0..N) {
      foreach(p; j+1..N) {
        string a;
        foreach(x; j..p+1) a ~= (grid[i][x]);
        all ~= a;
      }
      foreach(q; i+1..N) {
        string a;
        foreach(x; i..q+1) a ~= (grid[x][j]);
        all ~= a;
      }
    }
  }

  all.sort.joiner("\n").deb;
  return all.length == all.sort.uniq.array.length;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
