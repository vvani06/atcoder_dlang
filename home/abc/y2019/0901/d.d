import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;

void main() {
  auto N = readln.chomp.to!ulong;
  ulong sum = 0;

  for(ulong i=0; i<N; i++) {
    sum += i;
  }

  writeln(sum);
}
