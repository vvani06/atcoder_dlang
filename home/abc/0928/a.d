import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  auto N = readln.chomp.to!float;
  writeln((N-(floor(N/2)))/N);
}
