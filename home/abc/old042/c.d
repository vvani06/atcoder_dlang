import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

int[] numberConcat(int[] a, int[] b) {
  int[] combinations;
  foreach(i; a) {
    foreach(o; b) {
      combinations ~= i*10 + o;
    }
  }
  return combinations;
}

void main() {
  int N, K; readf("%d %d\n", &N, &K);
  auto Dn = readln.split.to!(int[]).sort;
  auto likeNumbers = 10.iota.filter!(a => !Dn.any!(d => d == a)).array;

  foreach(size; N.to!string.length..6) {
    auto combinations = likeNumbers.dup;
    (size-1).iota.each!(x => combinations = numberConcat(combinations, likeNumbers));
    
    auto answers = combinations.filter!(x => x >= N);
    if (!answers.empty) {
      writeln(answers.front);
      break;
    }
  }
}
