import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  auto ABC = readln.split.to!(int[]).sort;
  writeln(ABC == [5, 5, 7] ? "YES" : "NO");
}
