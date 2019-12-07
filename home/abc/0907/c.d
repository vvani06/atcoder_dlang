import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  auto N = readln.chomp.to!int;
  auto Bn = readln.split.to!(int[]);

  int total = Bn[0] + Bn[N-2];
  foreach(i; 0..N-2) {
    total += min(Bn[i], Bn[i+1]);
  }

  writeln(total);
}
