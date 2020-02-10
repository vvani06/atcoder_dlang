import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  auto N = readln.chomp.to!ulong;
  ulong answer = N-1;

  for(ulong i = 1; i * i <= N; i++) {
    if (N % i != 0) continue;

    auto j = N/i;
    auto candidate = i-1 + j-1;
    if (candidate < answer) answer = candidate;
  }

  writeln(answer);
}
