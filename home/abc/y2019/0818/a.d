import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;

void main() {
  auto a = readln.chomp.to!int;
  auto s = readln.chomp;
  
  writeln(a >= 3200 ? s : "red");
}
