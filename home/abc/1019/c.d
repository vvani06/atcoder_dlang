import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  auto N = readln.chomp.to!int;
  auto S = readln;
  
  int total = 0;
  foreach(i; 0..N) {
    if (i == 0) {
      total++;
      continue;
    }
    if (S[i-1] == S[i]) continue;
    total++;
  }

  writeln(total);
}
