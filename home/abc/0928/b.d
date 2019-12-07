import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  int ninzu, limit;
  readf("%d %d\n", &ninzu, &limit);
  auto heights = readln.split.to!(int[]);

  auto count = heights.filter!(h => h >= limit).array.length;
  writeln(count);
}
