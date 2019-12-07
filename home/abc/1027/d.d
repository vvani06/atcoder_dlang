import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.numeric;
import std.math;

void main() {
  real a, b, x; readf("%g %g %g\n", &a, &b, &x);
  auto water_height = x/a/a;
  auto yoyuu = b - water_height;

  if (yoyuu <= water_height) {
    auto theta = atan2(yoyuu, 0.5L*a);
    writefln("%.10f", theta*180.0L/PI);
  } else {
    auto theta = atan2(b, 2*x/a/b);
    writefln("%.10f", theta*180.0L/PI);
  }
}
