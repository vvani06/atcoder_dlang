
T parseAsState(T)(int state) {
  T ret;
  static foreach(i; iota(T.SIZES.length).retro) {
    ret.tupleof[i] = state % T.SIZES[i];
    state /= T.SIZES[i];
  }
  return ret;
}

int composeStateInt(T)(T state) {
  int ret;
  static foreach(i, s; T.SIZES) {
    ret *= s;
    ret += state.tupleof[i];
  }
  return ret;
}

T[] allStates(T)() {
  return iota(T.SIZES.fold!"a * b").map!(i => parseAsState!T(i)).array;
}

// 桁DP usage: https://atcoder.jp/contests/abc465/submissions/77225486
auto digitDP(T, R)(string N, R[T] init) {
  enum size = T.SIZES.fold!"a * b";
  auto memo = new R[][](2, size);
  foreach(k, v; init) memo[0][composeStateInt(k)] = v;
  
  foreach(c; N.map!"(a - '0').to!long") {
    auto pre = new R[][](2, size);
    swap(pre, memo);

    foreach(from; 0..size) {
      auto fromState = parseAsState!T(from);

      foreach(d; 0..10) {
        auto toState = fromState.nextForDigitDP(d);
        auto to = composeStateInt(toState);

        memo[1][to] += pre[1][from];
        if (d < c) memo[1][to] += pre[0][from];
        if (d == c) memo[0][to] += pre[0][from];
      }
    }
  }
  return zip(memo[0], memo[1]).map!"a[0] + a[1]".array;
}
