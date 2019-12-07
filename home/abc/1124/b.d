import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;
import std.typecons;

void main() {
  auto N = readln.chomp.to!int;
  char[] S = cast(char[])readln.chomp;
  
  foreach(i; 0..S.length) {
    S[i] = 'A' + (S[i] - 'A' + N)%26;
  }

  S.writeln;
}
