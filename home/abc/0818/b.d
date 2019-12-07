import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;

void main() {
  auto N = readln.chomp.to!int;
  auto An = readln.split.to!(double[]);

  double sum = 0;
  foreach(a; An) {
    sum += 1.0 / a;
  }

  writefln("%.10f", 1.0f/sum);
}
