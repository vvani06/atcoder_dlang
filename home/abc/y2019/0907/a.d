import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.math;

void main() {
  auto N = readln.chomp.to!ulong;

  writeln(pow(N, 3));
}
