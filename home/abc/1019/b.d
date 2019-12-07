import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  auto N = readln.chomp.to!int;
  auto Dn = readln.split.to!(int[]);

  int total = 0;
  foreach(i; 0..N) {
    for(int o=i+1; o<N; o++) {
      total += Dn[i] * Dn[o];
    }
  }

  writeln(total);
}
