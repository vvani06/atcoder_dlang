import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  int x, y; readf("%d %d\n", &x, &y);

  auto prizes = [0, 300000, 200000, 100000];

  auto prize = 0;
  prize += x <= 3 ? prizes[x] : 0;
  prize += y <= 3 ? prizes[y] : 0;
  prize += x == 1 && y == 1 ? 400000 : 0;
  writeln(prize);
}
