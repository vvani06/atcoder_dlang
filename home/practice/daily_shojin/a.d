void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto WTB = M.iota.map!(_ => WantToBreak(scan!long, scan!long)).array;

  long solve() {
    long ans;
    long last = long.min;
    foreach(wtb; WTB.sort!"a.to < b.to") {
      if (last > wtb.from) continue;

      wtb.deb;
      last = wtb.to;
      ans++;
    }

    return ans;
  }

  writeln(solve());
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.bitmanip;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias WantToBreak = Tuple!(long, "from", long, "to");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

struct Set(T) {
  bool[T] set;

  this(T t) { set[t] = true; }
  this(T[] t) { foreach(tt; t) set[tt] = true; }

  Set add(T t) { set[t] = true; return this; }
  Set remove(T t) {set.remove(t); return this; }
  bool contains(T t) { return (t in set) != null; }
  long length() { return set.length; }
}