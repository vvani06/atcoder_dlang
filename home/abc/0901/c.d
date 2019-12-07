import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;

void main() {
  auto N = readln.chomp.to!int;
  auto Hn = readln.split.to!(int[]);

  int prev = Hn[0];
  int count = 0;
  int max_count = 0;
  foreach(h; Hn[1..Hn.length]) {
    if (h > prev) {
      count = 0;
      prev = h;
      continue;
    }
    if (max_count < ++count) max_count = count;
    prev = h;
  }
  writeln(max_count);
}
