void main() {
  problem();
}

ulong[] generatePrimes(ulong olimit)
{
  ulong limit;
  for(ulong i = 1; i*i <= olimit; i++) limit = i;

  bool[] PS = new bool[limit + 1];
  PS[] = true;
  PS[0] = false;
  PS[1] = false;
  for(ulong i = 2; i <= limit; i++) {
    if (PS[i]) {
      auto x = i*2;
      while (x <= limit) {
        PS[x] = false;
        x += i;
      }
    }
  }

  ulong[] primes;
  foreach(i; 2..limit+1) {
    if (PS[i]) primes ~= i;
  }

  return primes;
}
void problem() {
  auto N = scan!ulong;
  auto primesAll = generatePrimes(N^^2);

  ulong solve() {
    // diviers of 1 and primes
    ulong ans = primesAll.length * 2 + 2;
    const tenComb = [3: [2,3,5,7], 4: [4,9], 5: [6,8,10]];

    foreach(x; tenComb.keys) {
      foreach(np; tenComb[x]) {
        foreach(p; primesAll) {
          if (p * np > N) break;
          ans += x;
        }
      }
    }

    auto primes = generatePrimes((N/10)^^2);

    // diviers of not primes
    foreach(i, p; primes) {
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
alias Queue = Tuple!(long, "from", long, "to");

// -----------------------------------------------
