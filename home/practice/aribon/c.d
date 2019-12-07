import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;

void main() {
  auto S = readln.chomp;

  string solve(string input) {
    foreach(c; ['a','b','c']) {
      if (!input.canFind(c)) return "No";
    }
    return "Yes";
  }

  solve(S).writeln;
}
