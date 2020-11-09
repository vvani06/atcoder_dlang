void main() {
  initCom();
  problem();
}

const MAX = 100_000;
const MOD = 100_000_000_7;
long[] fac = new long[MAX];
long[] finv = new long[MAX];
long[] inv = new long[MAX];

// テーブルを作る前処理
void initCom() {
    fac[0] = fac[1] = 1;
    finv[0] = finv[1] = 1;
    inv[1] = 1;
    for (int i = 2; i < MAX; i++){
        fac[i] = fac[i - 1] * i % MOD;
        inv[i] = MOD - inv[MOD%i] * (MOD / i) % MOD;
        finv[i] = finv[i - 1] * inv[i] % MOD;
    }
}

// 二項係数計算
long com(int n, int k){
    if (n < k) return 0;
    if (n < 0 || k < 0) return 0;
    return fac[n] * (finv[k] * finv[n - k] % MOD) % MOD;
}

void problem() {
  const N = scan!long;
  const K = scan!long;

  long solve() {
    long ans;
    
    foreach(comb; iota(1, K+1).array.permutationsWithRepetitions(cast(int)N)) {
      long gcd = comb[0];
      foreach(c; comb[1..$]) gcd = gcd.gcd(c);

      ans = (ans + gcd) % MOD;
    }

    return ans;
  }

  solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.numeric, std.concurrency;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }

Generator!(T[]) permutationsWithRepetitions(T)(T[] data, in uint n)
in {
    assert(!data.empty && n > 0);
} body {
    return new typeof(return)({
        if (n == 1) {
            foreach (el; data)
                yield([el]);
        } else {
            foreach (el; data)
                foreach (perm; permutationsWithRepetitions(data, n - 1))
                    yield(el ~ perm);
        }
    });
}

// -----------------------------------------------
