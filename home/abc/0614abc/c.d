void main() {
  problem();
}

void problem() {
  const X = scan!int;
  const N = scan!int;
  const P = scan!int(N);

  int solve() {
    int absolute = 101;
    int answer = 101;

    auto NP = iota(0, 102, 1).filter!(a => !P.canFind(a));

    foreach(p; NP) {
      const a = X > p ? X - p : p - X;
      if (a == absolute && answer > p) {
        answer = p;
        continue;
      }
      if (a < absolute) {
        answer = p;
        absolute = a;
        continue;
      }
    }

    return answer;
  }

  solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
