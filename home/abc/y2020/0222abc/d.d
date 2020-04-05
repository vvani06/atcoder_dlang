import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
import std.bigint, std.functional;

const MOD = 1000000000 + 7;

class FermetCalculator {
  long[] factrial; //階乗を保持
  long[] inverse;  //逆元を保持
  
  this(long size) {
    factrial = new long[size + 1];
    inverse = new long[size + 1];
    factrial[0] = 1;
    inverse[0] = 1;
    
    for (long i = 1; i <= size; i++) {
      factrial[i] = (factrial[i - 1] * i) % MOD;  //階乗を求める
      inverse[i] = pow(factrial[i], MOD - 2) % MOD; // フェルマーの小定理で逆元を求める
    }
  }
  
  long combine(long n, long k) {
    return factrial[n] * inverse[k] % MOD * inverse[n - k] % MOD;
  }
  
  long combine_naive(long n, long k) {
    auto bunshi = reduce!((x, i) => (x * (n - i + 1)) % MOD)(1L, iota(1, k+1));
    auto bumbo = reduce!((x, i) => (x * i) % MOD)(1L, iota(1, k+1));
    return bunshi * pow(bumbo, MOD - 2) % MOD;
  }
  
  long pow(long x, long n) { //x^n 計算量O(logn)
    long ans = 1;
    while (n > 0) {
      if ((n & 1) == 1) {
        ans = ans * x % MOD;
      }
      x = x * x % MOD; //一周する度にx, x^2, x^4, x^8となる
      n >>= 1; //桁をずらす n = n >> 1
    }
    return ans;
  }
}

void main() {
  auto INPUT = readln.split.to!(long[]);
  auto N = INPUT[0];
  auto A = INPUT[1];
  auto B = INPUT[2];

  auto fermetCalculator = new FermetCalculator(1);

  ulong solve() {
    auto answer = fermetCalculator.pow(2, N) - 1;
    auto a = fermetCalculator.combine_naive(N, A);
    auto b = fermetCalculator.combine_naive(N, B);

    answer = answer >= a ? answer - a : MOD - a + answer;
    answer = answer >= b ? answer - b : MOD - b + answer;

    return answer;
  }

  solve().writeln;
}
