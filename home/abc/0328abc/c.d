void main() {
  problem();
}

void problem() {
  const K = scan!int;
  const N = scan!int;
  const A = scan!(int)(N);

  int solve() {

    auto delta = new int[N];
    foreach(i; 0..N-1) {
      delta[i] = A[i+1] - A[i];
    }
    delta[N-1] = K - A[N-1] + A[0];

    int max;
    foreach(d; delta){
      if (max < d) max = d;
    }

    return delta.sum - max;
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
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
