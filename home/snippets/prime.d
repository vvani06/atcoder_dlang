
ulong[] primeFactoring(ulong target)
{
  ulong s = target.to!float.sqrt().floor.to!ulong;
  ulong num = target;
  ulong[] primes;
	for (ulong i = 2; i <= s; i++) {
    if (num % i != 0) continue;

		while (num%i == 0) num /= i;
    primes ~= i;
	}
  if (num > s) primes ~= num;
	return primes;
}

bool[] enumeratePrimes(long max)
{
  auto primes = new bool[](max + 1);
  primes[] = true;
  primes[0] = false;
  primes[1] = false;
  foreach (i; 2..max+1) {
    if (primes[i]) {
      auto x = i*2;
      while (x <= max) {
        primes[x] = false;
        x += i;
      }
    }
  }

  return primes;
}

struct Eratosthenes {
  bool[] isPrime;
  int[] rawPrimes;
  int[] spf;

  this(int lim) {
    isPrime = new bool[](lim + 1);
    isPrime[2..$] = true;
    spf = new int[](lim + 1);
    spf[] = int.max;
    spf[0..2] = 1;
    memo = new int[][](lim + 1, 0);

    foreach (i; 2..lim+1) {
      if (isPrime[i]) {
        spf[i] = i;

        auto x = i*2;
        while (x <= lim) {
          isPrime[x] = false;
          spf[x].chmin(i);
          x += i;
        }
      }
    }

    foreach(p; 2..lim + 1) {
      if (isPrime[p]) rawPrimes ~= p;
    }
  }

  auto primes() { return rawPrimes.assumeSorted; }

  int[int] factorize(int x) {
    int[int] ret;
    while(x > 1) {
      ret[spf[x]]++;
      x /= spf[x];
    }
    return ret;
  }

  int lpf(int x) {
    int ret = 1;
    while(x > 1) {
      ret = max(ret, spf[x]);
      x /= spf[x];
    }
    return ret;
  }

  int[][] memo;
  int[] divisors(int num) {
    if (num <= 1) return [1];
    if (!memo[num].empty) return memo[num];

    auto p = lpf(num);
    int t; for(auto n = num; n % p == 0; n /= p) t++;
    auto pres = this.divisors(num / (p ^^ t));
    
    int[] ret;
    foreach(c; 0..t + 1) {
      ret ~= pres.map!(pre => pre * (p ^^ c)).array;
    }
    ret.sort!"a > b";
    return memo[num] = ret;
  }
}

struct LinearSieze {
  int limit;
  int[] primes;
  int[] spf;

  this(int limit) {
    this.limit = limit;
    spf = new int[](limit + 1);

    foreach(d; iota(2, limit + 1)) {
      if (spf[d] == 0) {
        spf[d] = d;
        primes ~= d;
      }

      foreach(p; primes) {
        if (p * d > limit || p > spf[d]) break; else spf[p * d] = p;
      }
    }
  }

  alias Factors = Tuple!(int, int)[];
  Factors factors(int n) {
    Factors ret;
    for(auto prime = spf[n]; prime > 1;) {
      int count;
      while(n % prime == 0) {
        count++;
        n /= prime;
      }

      ret ~= tuple(prime, count);
      prime = spf[n];
    }
    return ret;
  }
}