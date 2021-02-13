void main() {
  problem();
}

void problem() {
  auto P = scan!real;

  auto solve() {
    real t334(real x) {
      return x + P/2L.pow(2L * x / 3L);
    }
    long twice(long x) {
      return x * x;
    }

    binarySearch(&twice, (long a) => a > 399, 0, 1000).writeln;

    const ret = triMinSearch(&t334, 0L, 10L.pow(18));
    return t334(ret);
  }

  static if (is(ReturnType!solve == void)) solve(); else solve().writeln;
}

// -----------------------------------------------

T triMinSearch(T)(T delegate(T) fn, T l, T r) {
  auto lb = l;
  auto ub = r;
  const T THREE = 3;

  while(true) {
    static if (is(T == float) || is(T == double) || is(T == real)) {
      if(lb.approxEqual(ub, 1e-08, 1e-08)) break;
    } else {
      if(lb == ub) break;
    }
    const c1 = lb + (ub - lb) / THREE;
    const c2 = ub - (ub - lb) / THREE;

    if (fn(c1) < fn(c2)) {
      ub = c2;
    } else {
      lb = c1;
    }
  }

  return lb;
}

T binarySearch(T)(T delegate(T) fn, bool delegate(T) cond, T l, T r) {
  auto lb = l;
  auto ub = r;
  const T TWO = 2;

  while(true) {
    static if (is(T == float) || is(T == double) || is(T == real)) {
      if(lb.approxEqual(ub, 1e-08, 1e-08)) break;
    } else {
      if(lb == ub || lb + 1 == ub) break;
    }
    const half = (ub + lb) / TWO;
    const halfValue = fn(half);

    if (cond(halfValue)) {
      ub = half;
    } else {
      lb = half;
    }
  }

  return ub;
}

string asString(T)(T r, long keta = 16) {
  return format("%."~keta.to!string~"f", r);
}


// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
