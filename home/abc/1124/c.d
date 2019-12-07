import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;

void main() {
  const MAX = 1000000000;
  long A, B, X; readf("%d %d %d\n", &A, &B, &X);

  long cost(long N) {
    return A * N + B * N.to!string.length;
  }

  long solve(long budget) {
    if (budget >= cost(MAX)) return MAX;

    long max = MAX;
    long min = 0;
    while(max - min > 1) {
      auto median = (max + min) / 2;
      auto cost = cost(median);
      if (budget == cost) return median;
      min = budget > cost ? median : min;
      max = budget > cost ? max : median;
    }
    
    return min;
  }

  solve(X).writeln;
}
