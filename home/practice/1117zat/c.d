void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto S = scan;

  void solve() {
    long[] leftAt = new long[N];
    long[] rightAt = new long[N];

    foreach(i; 1..N) {
      leftAt[i] = leftAt[i-1] + (S[i-1] == 'W' ? 1 : 0);
      rightAt[$-i-1] = rightAt[$-i] + (S[$-i] == 'E' ? 1 : 0);
    }

    leftAt.deb;
    rightAt.deb;

    N.iota.map!(a => leftAt[a] + rightAt[a]).reduce!min.writeln;
    
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
