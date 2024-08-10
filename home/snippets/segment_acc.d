
struct SegmentAcc(T) {
  T[][] acc;

  this(size_t h, size_t w, T[][] seg) {
    acc = new T[][](h + 1, w + 1);
    foreach(r; 0..h) foreach(c; 0..w) {
      acc[r + 1][c + 1] += acc[r][c + 1] + acc[r + 1][c] + seg[r][c];
      acc[r + 1][c + 1] -= acc[r][c];
    }
  }

  T sum(size_t t, size_t l, size_t b, size_t r) {
    T ret;
    ret += acc[t][l] + acc[b][r];
    ret -= acc[b][l] + acc[t][r];
    return ret;
  }
}
