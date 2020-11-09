void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto A = scan!long(N+1);
  auto B = scan!long(N);

  void solve() {
    long ans;

    foreach(i; 0..N) {
      const score = min(A[i], B[i]);
      A[i] -= score;
      B[i] -= score;
      ans += score;

      if (B[i] == 0) continue;

      const score2 = min(A[i+1], B[i]);
      A[i+1] -= score2;
      B[i] -= score2;
      ans += score2;
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
