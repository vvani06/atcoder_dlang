
Tuple!(long, long) inv_gcd(long a, long b) {
  a = (a % b + b) % b;
  if (a == 0) return tuple(b, 0L);

  auto s = b, t = a;
  long m0 = 0, m1 = 1;
  
  while(t) {
    const u = s / t;
    s -= t * u;
    m0 -= m1 * u;

    swap(s, t);
    swap(m0, m1);
  }

  if (m0 < 0) m0 += b / s;
  return tuple(s, m0);
}

Tuple!(long, long) crt(long[] r, long[] m) {
  assert(r.length == m.length);

  int n = r.length.to!int;
  long r0 = 0, m0 = 1;
  for(int i = 0; i < n; i++) {
    assert(1 <= m[i]);
    auto r1 = (r[i] % m[i] + m[i]) % m[i];
    auto m1 = m[i];
    if (m0 < m1) {
      swap(r0, r1);
      swap(m0, m1);
    }
    if (m0 % m1 == 0) {
      if (r0 % m1 != r1) return tuple(0L, 0L);
      continue;
    }

    const ig = inv_gcd(m0, m1);
    const g = ig[0], im = ig[1];

    const u1 = m1 / g;
    if ((r1 - r0) % g) return tuple(0L, 0L);

    const x = (r1 - r0) / g % u1 * im % u1;
    r0 += x * m0;
    m0 *= u1;
    if (r0 < 0) r0 += m0;
  }

  return tuple(r0, m0);
}
