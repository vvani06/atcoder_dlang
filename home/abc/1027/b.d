import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  bool[int] kuku_answers;
  foreach(i; 1..10) {
    foreach(o; 1..10) {
      kuku_answers[i*o] = true;
    }
  }
  
  auto N = readln.chomp.to!int;
  writeln(N in kuku_answers ? "Yes" : "No");
}
