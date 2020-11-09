import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;
import std.typecons;

void main() {
  auto N = readln.chomp.to!int;
  auto An = readln.split.to!(long[]);
  auto total = An.sum;

  long current_length_twice;
  long cost;
  foreach(index; 0..N) {
    current_length_twice += An[index]*2;
    if (current_length_twice == total) break;
    if (current_length_twice > total) {
      long previous_length_twice = current_length_twice - An[index]*2;
      long shrinkable_length = current_length_twice/2 - index - 1;

      long adjust_size_shrink = current_length_twice - total;
      long adjust_size_enlong = total - previous_length_twice;
      if (adjust_size_shrink < adjust_size_enlong && shrinkable_length >= adjust_size_shrink) {
        cost = adjust_size_shrink;
      } else {
        cost = adjust_size_enlong;
      }
      break;
    }
  }

  cost.writeln;
}
