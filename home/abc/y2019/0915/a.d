import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  auto S = readln.chomp;
  writeln(S == "Sunny" ? "Cloudy" : S == "Cloudy" ? "Rainy" : "Sunny");
}
