void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto W = scan!long;
  auto USE = N.iota.map!(x => User(scan!long(3))).array;

  void solve() {
    long[long] up;
    long[long] down;
    
    foreach(u; USE) {
      if (!(u[0] in up)) up[u[0]] = 0;
      up[u[0]] += u[2];
      if (!(u[1] in down)) down[u[1]] = 0;
      down[u[1]] += u[2];
    }

    long use;
    foreach(t; (up.keys ~ down.keys).sort.uniq) {
      if (t in up) use += up[t];
      if (t in down) use -= down[t];
      
      if (W < use) {
        writeln("No");
        return;
      }
    }

    writeln("Yes");
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
alias User = Tuple!(long, "up", long, "down", long, "amount");

// -----------------------------------------------
