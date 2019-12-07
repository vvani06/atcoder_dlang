import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;
import std.typecons;

class Path {
  public int from;
  public int to;
  public int color;

  this(int from, int to, int color) {
    this.from = from;
    this.to = to;
    this.color = color;
  }
}

void main() {
  auto N = readln.chomp.to!int;
  Path[][int] tree;
  Path[] allPaths;
  foreach(i; 1..N) {
    int from, to; readf("%d %d\n", &from, &to);
    auto path = new Path(from, to, 1);
    tree[from] ~= path;
    tree[to] ~= path;
    allPaths ~= path;
  }

  foreach(paths; tree) {
    if (paths.length == 1) continue;

    bool[int] colors;
    foreach(path; paths) {
      auto nextPath = tree[path.to].map!(p => p == path ? 0 : p.color).array;
      while (path.color in colors || nextPath.canFind(path.color)) {
        path.color++;
      }
      colors[path.color] = true;
    }
  }

  allPaths.map!(path => path.color).reduce!(max).writeln;
  foreach(path; allPaths) {
    path.color.writeln;
  }
}

