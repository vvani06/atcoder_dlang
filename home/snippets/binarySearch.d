K binarySearch(K)(bool delegate(K) cond, K l, K r) { return binarySearch((K k) => k, cond, l, r); }
T binarySearch(T, K)(K delegate(T) fn, bool delegate(K) cond, T l, T r) {
  auto ok = l;
  auto ng = r;
  const T TWO = 2;
 
  bool again() {
    static if (is(T == float) || is(T == double) || is(T == real)) {
      return !ng.approxEqual(ok, 1e-08, 1e-08);
    } else {
      return abs(ng - ok) > 1;
    }
  }
 
  while(again()) {
    const half = (ng + ok) / TWO;
    const halfValue = fn(half);
 
    if (cond(halfValue)) {
      ok = half;
    } else {
      ng = half;
    }
  }
 
  return ok;
}

enum TernarySearchTarget { Min, Max }
Tuple!(T, K) ternarySearch(T, K)(K delegate(T) fn, T l, T r, TernarySearchTarget target = TernarySearchTarget.Min) {
  auto low = l;
  auto high = r;
  const T THREE = 3;
 
  bool again() {
    static if (is(T == float) || is(T == double) || is(T == real)) {
      return !high.approxEqual(low, 1e-08, 1e-08);
    } else {
      return low != high;
    }
  }

  auto compare = (K a, K b) => target == TernarySearchTarget.Min ? a > b : a < b;
  while(again()) {
    const v1 = (low * 2 + high) / THREE;
    const v2 = (low + high * 2) / THREE;
 
    if (compare(fn(v1), fn(v2))) {
      low = v1 == low ? v2 : v1;
    } else {
      high = v2 == high ? v1 : v2;
    }
  }
 
  return tuple(low, fn(low));
}
