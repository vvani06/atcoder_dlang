void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto H = scan!long(N).sort.array;
  auto HS = H.assumeSorted;
  auto W = scan!long(M).sort.array;

  void solve() {
    long ans = long.max;

    long[] sumOdd = new long[N/2 + 1];
    long[] sumEven = new long[N/2 + 1];
    foreach(i; 0..N/2) {
      sumOdd[i+1] = sumOdd[i] + H[2*i + 1] - H[2*i + 0];
      sumEven[i+1] = sumEven[i] + H[2*i + 2] - H[2*i + 1];
    }

    sumOdd.deb;
    sumEven.deb;

    foreach(w; W) {
      const borderPairsCount = HS.lowerBound(w).length / 2;

      long sum;
      sum += sumOdd[borderPairsCount];
      sum += (H[2 * borderPairsCount] - w).abs;
      sum += sumEven[N/2] - sumEven[borderPairsCount];
      // foreach(pair; (H[0..border] ~ w ~ H[border..$]).chunks(2)) {
      //   sum += pair[1] - pair[0];
      // }

      ans = min(ans, sum);
    }

    ans.writeln;
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
