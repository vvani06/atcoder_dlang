import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  int a, b;
  readf("%d %d\n", &a, &b);
  int nokori = a - 2*b;
  writeln(nokori<0 ? 0: nokori);
}
