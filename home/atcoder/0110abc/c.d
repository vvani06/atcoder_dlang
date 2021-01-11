void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto A = scan!long(2^^N).indexed(1);

  void solve() {
    auto t = A.chunks(2^^(N - 1));
    t.map!"a.maxElement".minElement.index.writeln;
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
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

struct IndexedValue(I, T) {
  I index;
  T value;
  alias value this;

  this(I index, T value) {
    this.index = index;
    this.value = value;
  }
}

IndexedValue!(I, T)[] indexed(I, T)(T[] arr, I origin = 0L) {
  const l = arr.length.to!I;
  return iota(origin, origin + l).map!(i => IndexedValue!(I, T)(i, arr[i - origin])).array;
}

// -----------------------------------------------
