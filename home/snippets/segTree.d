struct SegTree(alias pred = "a + b", T = long) {
  alias predFun = binaryFun!pred;
  int size;
  T[] data;
  T monoid;

  T op(T a, T b) {
    if (a == monoid) return b;
    if (b == monoid) return a;
    return predFun(a, b);
  }
 
  this(T[] src, T monoid = T.init) {
    this.monoid = monoid;

    for(int i = 2; i < 2L^^32; i *= 2) {
      if (src.length <= i) {
        size = i;
        break;
      }
    }
    
    data = new T[](size * 2);
    foreach(i, s; src) data[i + size] = s;
    foreach_reverse(b; 1..size) {
      data[b] = op(data[b * 2], data[b * 2 + 1]);
    }
  }
 
  void update(int index, T value) {
    int i = index + size;
    data[i] = value;
    while(i > 0) {
      i /= 2;
      data[i] = op(data[i * 2], data[i * 2 + 1]);
    }
  }

  void add(int index, T value) {
    update(index, op(get(index), value));
  }
 
  T get(int index) {
    return data[index + size];
  }
 
  T sum(int a, int b, int k = 1, int l = 0, int r = -1) {
    if (r < 0) r = size;
    
    if (r <= a || b <= l) return monoid;
    if (a <= l && r <= b) return data[k];
 
    T leftValue = sum(a, b, 2*k, l, (l + r) / 2);
    T rightValue = sum(a, b, 2*k + 1, (l + r) / 2, r);
    return op(leftValue, rightValue);
  }

  T[] array() {
    return size.iota.map!(i => get(i)).array;
  }

  static if (__traits(hasMember, T, "opCmp")) {
    int lowerBound(T border) {
      return binarySearch((int t) => sum(0, t) < border, 0, size + 1);
    }

    int upperBound(T border) {
      return binarySearch((int t) => sum(t, size) < border, size, -1);
    }
  }

  private K binarySearch(K)(bool delegate(K) cond, K l, K r) { return binarySearch((K k) => k, cond, l, r); }
  private T binarySearch(T, K)(K delegate(T) fn, bool delegate(K) cond, T l, T r) {
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
}

long countInvertions(T)(T[] arr) {
  auto segtree = SegTree!("a + b", long)(new long[](arr.length));
  long ret;
  long pre = -1;
  int[] adds;
  foreach(a; arr.enumerate(0).array.sort!"a[1] > b[1]") {
    auto i = a[0];
    auto n = a[1];
    if (pre != n) {
      foreach(ai; adds) segtree.update(ai, segtree.get(ai) + 1);   
      adds.length = 0;
    }
    adds ~= i;
    pre = n;
    ret += segtree.sum(0, i);
  }
  return ret;
}
