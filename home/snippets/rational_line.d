struct Rational {
  long u, l = 1;
  this(long u) { this.u = u; }
  this(long u, long l) {
    if (l == 0) assert("lower number cannot be 0");

    if (l < 0) {
      u *= -1;
      l *= -1;
    }
    const g = gcd(u.abs, l);
    this.u = u / g;
    this.l = l / g;
  }

  Rational add(Rational o) {
    const nl = l * o.l;
    const nu = u * o.l + o.u * l;
    return Rational(nu, nl);
  }
  Rational sub(Rational o) { return add(Rational(-o.u, o.l)); }
  Rational mul(Rational o) { return Rational(u * o.u, l * o.l); }
  Rational div(Rational o) { return Rational(u * o.l, l * o.u); }

  Rational opBinary(string op: "+")(Rational o) { return add(o); }
  Rational opBinary(string op: "-")(Rational o) { return sub(o); }
  Rational opBinary(string op: "*")(Rational o) { return mul(o); }
  Rational opBinary(string op: "/")(Rational o) { return div(o); }
  void opAssign(T)(t v) { u = v; }

  int opCmp(Rational o) {
    const me = u * o.l;
    const other = o.u * l;
    return me > other ? 1 : me < other ? -1 : 0;
  }
}

struct Line {
  Rational a, b;
  
  this(T)(T from, T to) {
    long dx = to[0] - from[0];
    long dy = to[1] - from[1];
    if (dy == 0) {
      a = long.max;
      b = from[1];
    } else if (dx == 0) {
      b = from[0];
    } else {
      a = Rational(dy, dx);
      b = Rational(from[1]) - Rational(from[0])*a;
    }
  }
}
