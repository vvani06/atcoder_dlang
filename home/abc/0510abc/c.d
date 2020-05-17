void main() {
  problem();
}

void problem() {
  const N = scan!int;
  const M = scan!int;
  const X = scan!int;
  auto C = new int[N];
  int[][] A;

  foreach(i; 0..N) {
    C[i] = scan!int;
    A ~= scan!int(M);
  }

  int[] bitNums = N.iota.map!(x => 2.pow(x)).array;

  void solve() {
    int answer = int.max;
    foreach(combinationNumber; 0..2.pow(N)) {
      auto comb = bitNums.map!(b => (combinationNumber & b) == b);

      int price;
      auto manabi = new int[M];
      foreach(i; 0..N) {
        if (comb[i]) continue;

        price += C[i];
        foreach(a; 0..M) manabi[a] += A[i][a];
      }

      if (manabi.any!(m => m < X)) continue;
      if (answer > price) answer = price;
    }

    writeln(answer == int.max ? -1 : answer);
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
