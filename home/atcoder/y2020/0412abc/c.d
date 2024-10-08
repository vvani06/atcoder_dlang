void main() {
  problem();
}

void problem() {
  const K = scan!long;

  long solve() {
    long ans;
    foreach(a; 1..K+1) {
      foreach(b; 1..K+1) {
        foreach(c; 1..K+1) {
          ans += a.gcd(b).gcd(c);
        }
      }
    }

    return ans;
  }

  solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }

// -----------------------------------------------
