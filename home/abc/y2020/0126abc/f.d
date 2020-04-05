import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

alias Point = Tuple!(double, "x", double, "y");
alias Circle = Tuple!(double, "x", double, "y", double, "r");

void main() {
  auto N = readln.chomp.to!int;

  Point[] points;
  foreach (i; 0..N) {
    Point p; readf("%s %s\n", &p.x, &p.y);
    points ~= p;
  }

  double max_dist = -1;
  Tuple!(int, int) max_pair;
  for (int i=0; i<N-1; i++) {
    for (int o=i+1; o<N; o++) {
      double dist = (points[i].x - points[o].x).abs + (points[i].y - points[o].y).abs;
      if (max_dist < dist) {
        max_dist = dist;
        max_pair[0] = i;
        max_pair[1] = o;
      }
    }
  }

  Circle circle_2points(Point a, Point b) {
    return Circle(
      0.5*(a.x + b.x),
      0.5*(a.y + b.y),
      0.5*sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    );
  }

  bool in_circle(Circle c, Point p) {
    auto dist = pow(c.x - p.x, 2) + pow(c.y - p.y, 2);
    return pow(c.r, 2) >= dist;
  }

  double cross(Point a, Point b, Point c) {
    auto A = Point(b.x - a.x, b.y - a.y);
    auto B = Point(a.x - c.x, a.y - c.y);
    return A.x*B.y - A.y*B.x;
  }

  Circle circle3(Point a, Point b, Point c) {
    auto A = pow(b.x - c.x, 2) + pow(b.y - c.y, 2);
    auto B = pow(c.x - a.x, 2) + pow(c.y - a.y, 2);
    auto C = pow(a.x - b.x, 2) + pow(a.y - b.y, 2);
    auto S = cross(a, b, c);
    return Circle(0, 0, 0);
  }

  auto c = circle_2points(points[max_pair[0]], points[max_pair[1]]);

  while(true) {
    bool updated = false;
    foreach(p; points) {
      if (in_circle(c, p)) continue;

      auto d = c.r / (pow(p.x - c.x, 2) + pow(p.y - c.y, 2)).sqrt;
      auto x = Point(
        d * (c.x - p.x),
        d * (c.y - p.y)
      );

      c = circle_2points(p, x);
      updated = true;
    }
    if (!updated) break;
  }

  writefln("%.10f", c.r);
}
