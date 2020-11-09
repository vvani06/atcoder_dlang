void main() {
  problem();
}

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto K = scan!long;
  auto A = scan!long(N);
  auto B = scan!long(M);

  long solve() {
    long[] sumA = new long[N+1];
    foreach(i; 1..N+1) sumA[i] = sumA[i-1] + A[i-1];

    long[] sumB = new long[M+1];
    foreach(i; 1..M+1) sumB[i] = sumB[i-1] + B[i-1];

    sumA.deb;
    sumB.deb;

    long ans;
    long b = M;
    foreach(a; 0..N+1) {
      if (sumA[a] > K) continue;

      long rest = K - sumA[a];
      foreach_reverse(bi; 0..b+1) {
        if (sumB[bi] <= rest) {
          b = bi;
          break;
        }
      }
      
      if (ans < a + b) ans = a + b;
    }

    return ans;
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
