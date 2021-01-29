void main() {
  problem();
}

void problem() {
  const N = scan!long;
  const M = scan!long;

  long takahashi(Range[] ranges) {
    long left = long.min; 
    long right = long.min;
    long ans; 
    foreach(r; ranges.sort!("a.right < b.right")) {
      if (left < r.left && right < r.right) {
        left = r.left;
        right = r.right;
        ans++;
      }
    }
    deb("TAKAHASHI: ", ans);
    return ans;
  }

  long aoki(Range[] ranges) {
    long left = long.min; 
    long right = long.min;
    long ans; 
    foreach(r; ranges.sort!("a.left < b.left")) {
      if (left < r.left && right < r.right) {
        left = r.left;
        right = r.right;
        ans++;
      }
    }
    deb("AOKI: ", ans);
    return ans;
  }

  long calc(Range[] ranges) {
    return takahashi(ranges) - aoki(ranges);
  }

  void solve() {
    if (M < 0 || M == N) {
      writeln(-1);
      return;
    }

    if (!(N == 1 || N >= M + 2)) {
      writeln(-1);
      return;
    }

    Range[] ranges;

    const OFFSET = 10^^7;
    foreach(i; 0..(M == 0) ? N : N-1) {
      ranges ~= Range(1 + OFFSET + 3*i, 2 + OFFSET + 3*i);
    }

    if (M > 0) {
      ranges ~= Range(OFFSET + 3*(N - abs(M) - 2), 10^^8);
    }

    ranges.each!(r => writefln("%s %s", r.left, r.right));

    calc(ranges).deb;
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
alias Range = Tuple!(long, "left", long, "right");

// -----------------------------------------------
