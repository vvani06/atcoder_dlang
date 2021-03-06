
struct Vector2 {
  real x, y;
  this(real x, real y) { this.x = x; this.y = y; }
  Vector2 add(Vector2 other) { return Vector2(x + other.x, y + other.y ); }
  Vector2 sub(Vector2 other) { return Vector2(x - other.x, y - other.y ); }
  Vector2 div(real num) { return Vector2(x / num, y / num); }

  real norm() { return x*x + y*y; }
  real length() { return norm.sqrt; }
  Vector2 rotate(real theta) { return Vector2(x*cos(theta) - y*sin(theta), x*sin(theta) + y*cos(theta)); }

  string toString() { return "%.16f %.16f".format(x, y); }
}
