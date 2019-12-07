import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;
import std.typecons;

void main() {
  auto N = readln.chomp.to!int;
  int[] prices;
  foreach(i; 0..50000) {
    auto price = cast(int)(1.08f * cast(real)i);
    if (price == N) {
      prices ~= i;
    } 
  }

  if (prices.length == 0) {
    writeln(":(");
  } else {
    writeln(prices[0]);
  }
}
