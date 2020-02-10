import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;
import std.typecons;

alias Location = Tuple!(int, "x", int, "y");

void main() {
  auto N = readln.chomp.to!int;
  Location[] townLocations;
  foreach(i; 0..N) {
    int x, y; readf("%d %d\n", &x, &y);
    townLocations ~= Location(x, y)
  }

  auto T = S[0..N];
  writeln(T ~ T == S ? "Yes" : "No");
}
