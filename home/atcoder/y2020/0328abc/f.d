void main() {
  problem();
}

void problem() {
  auto N = scan!int, S = scan!int;
  const A = scan!(int)(N);

  long f(int l, int r) {
    long ans;
    foreach(size; l+1..r+1) {
      auto tmpSum = A[l..size].sum;
      if (tmpSum == S) ans++;
      foreach(offset; 0..r-size-1) {
        tmpSum += A[offset+size+1] - A[offset];
        if (tmpSum == S) ans++;
      }
    }
    return ans;
  }

  long solve() {
    long ans;
    foreach(l; 0..N+1) {
      foreach(r; l+1..N+1) {
        ans += f(l, r);
      }
    }
    return ans;
  }

  solve().writeln;
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
