import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;

void main() {
  int a, b;
  readf("%d %d\n", &a, &b);

  if (b == 1) {
    writeln("0");
  } else {
    int increase = a - 1;
    int add_count = b - 1;
    int count = add_count / increase + ((add_count % increase) > 0 ? 1 : 0);
    writeln(count);
  }
}
