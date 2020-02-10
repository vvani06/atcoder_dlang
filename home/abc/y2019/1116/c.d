import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;
import std.typecons;
import std.algorithm : permutations, nextPermutation;

alias Location = Tuple!(int, "x", int, "y");
const FloatWriter = "%.10f";

void main() {
  auto N = readln.chomp.to!int;
  Location[] locations;
  foreach(i; 0..N) {
    int x, y; readf("%d %d\n", &x, &y);
    locations ~= Location(x, y);
  }

  real distance = 0;
  int count = 0;
  foreach(route; iota(N).permutations) {
    int prev = route[0];
    foreach(next; route[1..N]) {
      auto distance_x = locations[prev].x - locations[next].x;
      auto distance_y = locations[prev].y - locations[next].y;
      distance += (cast(real)(distance_x*distance_x + distance_y*distance_y)).sqrt;
      prev = next;
    }
    count++;
  }

  FloatWriter.writefln(distance/count);
}
