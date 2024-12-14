
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
}

