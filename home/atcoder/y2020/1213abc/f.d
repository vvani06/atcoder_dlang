void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto Q = scan!long;
  auto A = [0L] ~ scan!long(N);
  auto T = Q.iota.map!(_ => Queue(scan!long, scan!long, scan!long, 0)).array;

  void solve() {
    long[] acc;
    acc.length = N + 1;
    foreach(i; 1..N+1) acc[i] = acc[i-1] ^ A[i];
    acc.deb;

    auto Printers = T.filter!(t => t.t == 2).array;
    long printers = Printers.length;
    long printed;

    long[long] patch;
    foreach(q; T) {
      if (q.t == 1) {
        acc[q.x..$] ^= q.y;
      } else {
        long ans = acc[q.y] ^ acc[q.x - 1];
        ans.writeln;
        printed++;
      }
    }

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
alias Queue = Tuple!(long, "t", long, "x", long, "y", long, "z");

// -----------------------------------------------
