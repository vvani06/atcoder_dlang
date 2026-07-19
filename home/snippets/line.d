
struct Line {
  // ax + by + c = 0
  long a, b, c;

  private void normalize() {
    long g = gcd(abs(a), gcd(abs(b), abs(c)));
    if (g > 0) {
      a /= g;
      b /= g;
      c /= g;
    }

    // 符号規約:
    //   a > 0
    //   a == 0 のとき b > 0
    if (a < 0 || (a == 0 && b < 0)) {
      a = -a;
      b = -b;
      c = -c;
    }
  }

  // ax + by + c = 0 を直接指定
  this(long a, long b, long c) {
    this.a = a;
    this.b = b;
    this.c = c;
    normalize();
  }

  // (px, py) - (qx, qy) を通る直線
  this(long px, long py, long qx, long qy) {
    a = qy - py;
    b = px - qx;
    c = -(a * px + b * py);
    normalize();
  }

  bool parallel(const Line rhs) const {
    return a * rhs.b - rhs.a * b == 0;
  }

  // 偏角ソートを想定した比較関数
  int opCmp(const Line rhs) const {
    if (a != rhs.a) return a < rhs.a ? -1 : 1;
    if (b != rhs.b) return b < rhs.b ? -1 : 1;
    return 0;
  }

  // この直線の法線で、(x, y) を通るものを返す
  Line normal(long x, long y) const {
    return Line(
      b,
      -a,
      -(b * x - a * y)
    );
  }
}
