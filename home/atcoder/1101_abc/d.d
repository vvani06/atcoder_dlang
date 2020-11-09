void main() {
  problem();
}

void problem() {
  auto SO = scan;
  auto S = SO.map!(c => c - '0').array;

  bool solve() {
    auto numbers = new long[10];
    foreach(s; S) numbers[s]++;

    xxx: foreach(i; 0..1000) {
      if (i % 8 != 0) continue;
      const s = i.to!string;

      if (s.canFind('0')) continue;
      if (i < 111 && SO.length != s.length) continue;

      auto n = numbers.dup;
      foreach(c; s) {
        if (--n[c - '0'] == -1) continue xxx;
      }

      s.deb;
      return true;
    }

    return false;
  }

  writeln(solve() ? "Yes" : "No");
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
