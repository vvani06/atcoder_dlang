void main() {
  problem();
}

void problem() {
  auto N = scan!int;
  auto Q = scan!int;
  auto An = scan!ulong(N);
  auto Sn = scan!ulong(Q);

  void solve() {
    auto acc = new ulong[N+1];
    foreach(i; 0..N) {
      acc[i+1] = acc[i].gcd(An[i]);
    }

    T findIndexBinary(T)(T x, bool delegate(T) tester) {
      ulong head = 1;
      if (tester(head)) return head;

      ulong tail = N;
      if (!tester(tail)) return 0;

      while(true) {
        ulong center = (head + tail) / 2;
        if (tester(center)) {
          if (tail == center) return tail;
          tail = center;
        } else {
          if (head == center) center++;
          head = center;
        }
      }
    }

    foreach(x; Sn) {
      auto gcdZero = (ulong i) => acc[i].gcd(x) == 1;
      auto index = findIndexBinary(x, gcdZero);
      writeln(index == 0 ? acc.back.gcd(x) : index);
    }
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.numeric, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
