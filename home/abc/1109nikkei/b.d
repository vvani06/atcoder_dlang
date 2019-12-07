import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;
import std.functional;

ulong factorial(int n, int r) {
  if (n <= 0 || r <= 0) return 1;
  return (n * memoize!factorial(n-1, r-1)) % 998244353;
}

ulong calcCombination(int n, int r) {
  if (n - r < r) return memoize!calcCombination(n, n-r);
  return memoize!factorial(n, r) / memoize!factorial(r, r);
}

ulong calcGraphLineCombination(int from, int to) {
  if (from <= 0 || to <= 0) return 1;
  if (from == 1) return 1;
  if (to == 1) return from;

  ulong sum = 0;
  foreach(n; 0..to+1) {
    sum += memoize!calcCombination(to, n) * memoize!calcGraphLineCombination(from-1, to-n);
    sum %= 998244353;
  }
  return sum;
}

void main() {
  auto N = readln.chomp.to!int;
  auto Di = readln.split.to!(int[]);

  if (Di[0] != 0) {
    writeln(0);
    exit(0);
  }

  Di = Di.sort;
  ulong answer = 1;
  int from = 1;
  int index = 1;
  foreach(i; 1..1 + Di[Di.length - 1]) {
    int beforeIndex = index;
    for(; index < N && Di[index] == i; index++) {}
    int to = index - beforeIndex;
    if (to == 0) {
      answer = 0;
      break;
    }
    for(int n = 0; n < to; n++) {
      answer *= from;
      answer %= 998244353;
    }
    if (index == N) break;
    from = to;
  }

  answer.writeln;
}
