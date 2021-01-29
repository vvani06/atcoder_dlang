void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto S = scan!string;

  void solve() {
    foreach(_; 0..N/3+1) {
      [[_]].deb;
      string origin = S;
      for(long i = 0; i < N-2; i++) {
        S[i..i+3].deb;
        if (S[i..i+3] == "fox") {
          S = S[0..i] ~ S[i+3..$];
          i = max(-1, i-2);
          N -= 3;
          [i, N-2].deb;
          S.deb;
          continue;
        }
      }
      if (S == origin) {
        writeln(S.length);
        return;
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
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
