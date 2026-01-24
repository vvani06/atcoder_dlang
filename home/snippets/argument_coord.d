
// 偏角ソートに対応した比較関数を持つ (x, y) 2次元座標
struct ArgumentCoord {
  int id;
  long x, y;

  inout long cross(inout ArgumentCoord other) {
    return x * other.y - y * other.x;
  }

  inout int opCmp(inout ArgumentCoord other) {
    auto ap = [0L, 0L] >= [y, x];
    auto aq = [0L, 0L] >= [other.y, other.x];
    if (ap < aq) return -1;
    if (ap > aq) return 1;

    if (cross(other) < 0) return 1;
    if (cross(other) > 0) return -1;
    return 0;
  }

  bool opEquals(ArgumentCoord other) {
    return cmp([this], [other]) == 0;
  }
}
