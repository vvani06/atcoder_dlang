
long[][] basePacks(long base, long size) {
  auto ret = new long[][](base^^size, size);
  foreach(i; 0..base^^size) {
    long x = i;
    foreach(b; 0..size) {
      ret[i][b] = x % base;
      x /= base;
    }
  }
  return ret;
}