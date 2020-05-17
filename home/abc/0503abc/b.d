void main() {
  problem();
}

void problem() {
  auto N = scan!int;
  auto K = scan!int;

  void solve() {
    bool[int] snk;
    foreach(i; 1..N+1) {
      snk[i] = true;
    }

    foreach(_; 0..K) {
      auto d = scan!int;
      foreach(i; scan!int(d)) {
        snk[i] = false;
      }
    }

    int answer;
    foreach(key; snk.keys()) {
      if (snk[key] == true) answer++;
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
