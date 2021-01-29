void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto A = scan!long(N);

  void solve() {
    long[] sumStack = new long[N+1];
    long[] forward = new long[N+1];
    foreach(i; 1..N+1) {
      sumStack[i] = sumStack[i - 1] + A[i - 1];
      forward[i] = max(sumStack[i], forward[i-1]);
    }
    forward[N] = 0;
    sumStack.deb;
    forward.deb;
    
    // 現在地
    long[] sumStack2 = new long[N+1];
    foreach(i; 1..N+1) {
      sumStack2[i] = sumStack2[i - 1] + sumStack[i];
    }
    sumStack2.deb;

    long ans;
    foreach(i; 0..N+1) {
      ans = max(ans, sumStack2[i] + forward[i]);
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
