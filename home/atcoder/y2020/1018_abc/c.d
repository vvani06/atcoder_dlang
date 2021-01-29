void main() {
  problem();
}

void problem() {
  const N = scan!ulong;

  void solve() {
    auto primes = N.primeFactoring;
    int[ulong] primesCount;
    bool[ulong] done;
    foreach(p; primes) primesCount[p]++;

    ulong[] ans = [N];
    void dfs(ulong value, int[ulong] pc) {
      done[value] = true;
      foreach(p; pc.keys) {
        if (pc[p] == 0) continue;

        pc[p]--;
        auto v = value / p;
        ans ~= v;

        if (!(v in done)) dfs(v, pc);
        pc[p]++;
      }
    }
    
    dfs(N, primesCount);

    ans.sort().uniq.each!(x => x.writeln);
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
