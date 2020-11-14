void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto Constraints = M.iota.map!(_ => scan!long(2)).array;

  void solve() {
    
    foreach(n; (N == 1 ? 0 : 10^^(N-1))..10^^N) {
      auto isOk = Constraints.all!((c) {
        const decBits = N - c[0];
        return c[1] == n.decAt(decBits);
      });

      if (isOk) {
        n.writeln;
        return;
      }
    }

    (-1).writeln;
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
T decAt(T)(T t, long i){ return (t % (10^^(i+1))) / (10^^i); }

// -----------------------------------------------
