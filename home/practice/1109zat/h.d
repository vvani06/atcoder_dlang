void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto A = scan!long(N);

  void solve() {
    auto sumStack = new long[N];
    sumStack[0] = A[0];
    foreach(i; 1..N) sumStack[i] = sumStack[i-1] + A[i];

    const full = sumStack[$-1];
    const halfIndex = sumStack.assumeSorted.lowerBound(full / 2).length;
    const left = sumStack[halfIndex - 1];
    const right = sumStack[halfIndex];
    const adjust = min(full - 2*left, 2*right - full);
    writeln(adjust);
    aaaa;
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
