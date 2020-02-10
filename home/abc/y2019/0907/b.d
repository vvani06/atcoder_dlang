import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  auto N = readln.chomp.to!ulong;
  auto An = readln.split.to!(int[]);
  auto Bn = readln.split.to!(int[]);
  auto Cn = 0 ~ readln.split.to!(int[]);

  int prev = -1;
  int satisfaction = 0;
  foreach(i; An) {
    i--;

    satisfaction += Bn[i];
    if (prev == i-1) satisfaction += Cn[i];
    prev = i;
  }

  writeln(satisfaction);
}
