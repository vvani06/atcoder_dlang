
struct Vector2(T) {
  T x, y;
  Vector2 add(Vector2 other) { return Vector2(x + other.x, y + other.y ); }
  Vector2 opBinary(string op: "+") (Vector2 other) { return add(other); }
  Vector2 sub(Vector2 other) { return Vector2(x - other.x, y - other.y ); }
  Vector2 opBinary(string op: "-") (Vector2 other) { return sub(other); }
  T norm(Vector2 other) { return (x - other.x)*(x - other.x) + (y - other.y)*(y - other.y); }
  T dot(Vector2 other) { return x*other.y - y*other.x; }
  Vector2 normalize() { if (x == 0 || y == 0) return Vector2(x == 0 ? 0 : x/x.abs, y == 0 ? 0 : y/y.abs);const gcd = x.abs.gcd(y.abs);return Vector2(x / gcd, y / gcd);}
  Vector2 rotate() { return Vector2(-y, x); }
  T min() { return .min(x, y); }
  T max() { return .max(x, y); }
}