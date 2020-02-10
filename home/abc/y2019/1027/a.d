import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  int a, b;
  readf("%d %d\n", &a, &b);
  writeln( a>9 || b>9 ? -1 : a*b);
}
