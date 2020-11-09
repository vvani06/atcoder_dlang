import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  int[] answers;
  answers ~= readln.chomp.to!int;
  answers ~= readln.chomp.to!int;
  answers = answers.sort().array;

  if (answers[0] == 1 && answers[1] == 2) writeln(3);
  if (answers[0] == 1 && answers[1] == 3) writeln(2);
  if (answers[0] == 2 && answers[1] == 3) writeln(1);
}
