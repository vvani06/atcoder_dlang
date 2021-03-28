void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto A = scan!string(N).map!(a => a == "AND").array;

  void solve() {
    long[] dpF;
    long[] dpT;
    dpF.length = N + 1;
    dpT.length = N + 1;
    dpF[0] = 1;
    dpT[0] = 1;

    foreach(i; 1..N+1) {
      if (A[i - 1]) {
        dpF[i] = dpF[i - 1]*2 + dpT[i - 1];
        dpT[i] = dpT[i - 1];
      } else {
        dpF[i] = dpF[i - 1];
        dpT[i] = dpT[i - 1]*2 + dpF[i - 1];
      }
    }
    
    dpT[$ - 1].writeln;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias City = Tuple!(long, "a", long, "t");
