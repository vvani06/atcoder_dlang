import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;

void main() {
  auto N = readln.chomp.to!int;
  auto Vn = readln.split.to!(float[]).sort();

  auto sum = Vn[0];
  foreach(v; Vn[1..N]) {
    sum = (sum + v) * 0.5;
  }

  writefln("%.10f", sum);
}
