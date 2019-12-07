import std.stdio, std.conv, std.array;
import std.algorithm;

void main() {
  int a, b;
  readf("%d %d\n", &a, &b);

  writeln(max(a+b, a-b, a*b));
}
