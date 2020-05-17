void main() {
  problem();
}

void problem() {
  const N = scan!int;
  const A = scan!long(N);

  void solve2() {
    auto B = N.iota.map!(i => A[i] + i).array;

    int[long] C;
    foreach(i; 0..N) {
      C[i - A[i]]++;
    }
    
    long answer;
    foreach(b; B) {
      if (b in C) answer += C[b];
    }

    writeln(answer);
  }

  // solve();
  solve2();
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
