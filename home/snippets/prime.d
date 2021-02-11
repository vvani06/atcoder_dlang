import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.numeric;
import std.math;

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

void main() {
  ulong N, M; readf("%d %d\n", &N, &M);
  ulong[] commonDiviers;
  ulong greatest = gcd(N, M);

  auto answerDivisers = primeFactoring(greatest);
  writeln(answerDivisers.length + 1);
}
