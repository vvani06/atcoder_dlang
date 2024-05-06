
struct RollingHash {
  ulong[] hashes = [0];
  ulong[] powers = [1];

  enum ulong MOD = 2L^^61 - 1;
  static uint seed;
  static ulong base;

  static this() {
      base = uniform(2, MOD - 1);
      seed = unpredictableSeed;
  }

  ulong mul(ulong a, ulong b) {
      Int128 c = a;
      c *= b;
      c %= MOD;
      return c.data.lo;
  }

  this(T)(T[] arr) {
      foreach(i, a; arr) {
      hashes ~= (mul(hashes[i], base) + a.hashOf(seed)) % MOD;
      powers ~= mul(powers[i], base) % MOD;
      }
  }

  ulong get(size_t l, size_t r) {
      return (MOD + hashes[r] - mul(powers[r - l], hashes[l])) % MOD;
  }
}
