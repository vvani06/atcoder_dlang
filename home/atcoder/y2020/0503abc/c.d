void main() {
  problem();
}

void problem() {
  const N = scan!int;
  const M = scan!int;
  const Heights = scan!long(N);
  const Pathes = M.iota.map!(x => scan!int(2)).map!(x => [x[0] - 1, x[1] - 1]).array;

  void solve() {
    int[][] allPathes;
    allPathes.length = N;
    allPathes[] = [];

    foreach(p; Pathes) {
      allPathes[p[0]] ~= p[1];
      allPathes[p[1]] ~= p[0];
    }

    int answer;
    foreach(i; 0..N) {
      if (allPathes[i].any!(x => Heights[x] >= Heights[i])) continue;

      answer++;
    }

    writeln(answer);
  }

  solve();
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
