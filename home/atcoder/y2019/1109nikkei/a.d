import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  auto N = readln.chomp.to!ulong;
  auto halfN = N / 2;
  writeln(halfN - (N%2 == 0 ? 1 : 0));
}
