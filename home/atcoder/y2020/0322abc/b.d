void main() {
  problem();
}

void problem() {
  auto S = scan;
  auto N = S.length;

  bool solve() {
    auto head = S[0..(N-1)/2];
    auto tail = S[(N+3)/2-1..$];

    S.deb;
    head.deb;
    tail.deb;

    auto s = S;
    for(long i = 0; i < s.length/2; i++) {
      if (s[i] != s[$-i-1]) return false;
    }

    s = head;
    for(long i = 0; i < s.length/2; i++) {
      if (s[i] != s[$-i-1]) return false;
    }

    s = tail;
    for(long i = 0; i < s.length/2; i++) {
      if (s[i] != s[$-i-1]) return false;
    }

    return true;
  }

  writeln(solve() ? "Yes" : "No");
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
