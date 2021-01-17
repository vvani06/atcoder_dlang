void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto C = N.iota.map!(_ => City(scan!long, scan!long)).array;

  void solve() {
    auto aoki = C.map!"a.a".sum;

    long ans;
    foreach_reverse(e; C.map!"2*a.a + a.t".array.sort()) {
      ans++;
      if ((aoki -= e) < 0) {
        writeln(ans);
        return;
      }
    }
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
