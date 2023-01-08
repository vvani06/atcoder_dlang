struct Miller {
  enum long[] v = [2, 7, 61];

  long modpow(long x, long k, long m) {
    long res = 1;
    while(k) {
      if (k & 1) {
        res = res * x % m;
      }
      k /= 2;
      x = x * x % m;
    }
    return res;
  }

  bool check(long n) {
    if (n < 2) return false;

    long d = n - 1;
    long s = 0;
    while(d % 2 == 0) {
      d /= 2;
      s++;
    }
    foreach(a; v) {
      if (a == n) return true;

      if (modpow(a, d, n) != 1) {
        bool ok = true;
        for(long r = 0; r < s; r++) {
          if (modpow(a, d * (1L << r), n) == n - 1) {
            ok = false;
            break;
          }
        }
        if (ok) return false;
      }
    }
    return true;
  }
}

struct Rho {
  Miller miller;
  long c;

  long mt() {
    return uniform(0, 2L^^62);
  }

  long f(long x, long n) {
    return (x * x + c) % n;
  }

  long check(long n) {
    if (n == 4) return 2;

    c = mt() % n;
    long x = mt() % n;
    long y = x;
    long d = 1;
    while(d == 1) {
      x = f(x, n);
      y = f(f(y, n), n);
      d = gcd(abs(x - y), n);
    }
    if (d == n) return -1;
    return d;
  }

  long[] factor(long n) {
    if (n <= 1) return [];
    if (miller.check(n)) return [n];

    long res = -1;
    while(res == -1) {
      res = check(n);
    }

    long[] fa = factor(res);
    long[] fb = factor(n / res);
    return fa ~ fb;
  }
}

void problem() {
  auto T = scan!int;
  auto N = scan!ulong(T);
  
  auto solve() {
    Rho rho;
    foreach(n; N) {
      int[long] c;
      foreach(f; rho.factor(n)) c[f]++;

      long p, q;
      foreach(k, v; c) {
        if (v == 1) q = k; else p = k;
      }

      writefln("%s %s", p, q);
    }
  }

  outputForAtCoder(&solve);
}
