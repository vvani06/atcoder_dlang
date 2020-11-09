void main() {
  problem();
}

void problem() {
  auto N = scan!ulong;

  ulong solve() {
    auto primes = primeFactoring(N);

    int[ulong] primeCounts;
    foreach(p; primes) {
      primeCounts[p]++;
    }

    ulong answer;
    foreach(p; primeCounts.keys) {
      const count = primeCounts[p];

      int sumCount;
      foreach(i; 1..count+1) {
        sumCount += i;
        if (sumCount > count) break;

        answer++;
      }
    }

    return answer;
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

ulong[] primeFactoring(ulong target)
{
  ulong s = target.to!float.sqrt().floor.to!ulong;
  ulong num = target;
  ulong[] primes;
	for (ulong i = 2; i <= s; i++) {
    if (num % i != 0) continue;

		while (num%i == 0) {
      num /= i;
      primes ~= i;
    }
	}
  if (num > s) primes ~= num;
	return primes;
}

// -----------------------------------------------
