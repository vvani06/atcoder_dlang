void main() {
  problem();
}

void problem() {
  auto a = scan!long;
  auto b = scan!long;
  auto c = scan!long;
  auto d = scan!long;

  long solve() {

    [a,b,c,d].deb;

    if ((b <= 0 && c >= 0) || (a >= 0 && d <= 0)) {
      return -1 * min(abs(a), abs(b)) * min(abs(c), abs(d));
    }

    deb("aaa");

    return max(abs(a), abs(b)) * max(abs(c), abs(d));
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
