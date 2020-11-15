
struct GridPoint {
  static enum ZERO = GridPoint(0, 0);
  long x, y;
  this(long x, long y) {
    this.x = x;
    this.y = y;
  }

  inout GridPoint left() { return GridPoint(x - 1, y); }
  inout GridPoint right() { return GridPoint(x + 1, y); }
  inout GridPoint up() { return GridPoint(x, y - 1); }
  inout GridPoint down() { return GridPoint(x, y + 1); }
  inout GridPoint leftUp() { return GridPoint(x - 1, y - 1); }
  inout GridPoint leftDown() { return GridPoint(x - 1, y + 1); }
  inout GridPoint rightUp() { return GridPoint(x + 1, y - 1); }
  inout GridPoint rightDown() { return GridPoint(x + 1, y + 1); }
  inout T of(T)(inout ref T[][] grid) { return grid[y][x]; }
}

struct GridValue(T) {
  T nullValue;
  GridPoint size;
  T[][] g;

  this(GridPoint p, T nullValue) {
    size = p;
    foreach(y; 0..size.y) g ~= new T[size.x];
    this.nullValue = nullValue;
  }

  this(long width, long height, T nullValue) {
    this(GridPoint(width, height), nullValue);
  }

  bool contains(GridPoint p) { return (0 <= p.y && p.y < size.y && 0 <= p.x && p.x < size.x); }
  T at(GridPoint p) { return contains(p) ? g[p.y][p.x] : nullValue; }
  T opIndex(GridPoint p) { return at(p); }
  T setAt(GridPoint p, T value) { return contains(p) ? g[p.y][p.x] = value : nullValue; }
  T opIndexAssign(T value, GridPoint p) { return setAt(p, value); }
}
