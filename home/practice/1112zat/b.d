void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto K = scan!long;

  void solve() {
    long ans;

    const minX = max(2, K + 2);
    const maxX = min(2*N, 2*N + K);
    [minX, maxX].deb;
    foreach(x; minX..maxX + 1) {
      const combX = x - 1 - (x - 1 > N ? 2*(x - 1 - N) : 0);
      const y = x - K;
      const combY = y - 1 - (y - 1 > N ? 2*(y - 1 - N) : 0);
      [x, y, combX, combY].deb;
      ans += combX * combY;
    }

    ans.writeln;
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
