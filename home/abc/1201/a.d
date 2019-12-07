import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  long M1, D1; readf("%d %d\n", &M1, &D1);
  long M2, D2; readf("%d %d\n", &M2, &D2);
  
  writeln(M1 == M2 ? "0" : "1");
}
