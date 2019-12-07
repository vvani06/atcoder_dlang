import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  auto N = readln.chomp;
  auto days = ["SUN","MON","TUE","WED","THU","FRI","SAT"];

  100f.dig.writeln;

  foreach(i; 0..7) {
    if (N == days[i]) {
      writeln(7-i);
    }
  }
}
