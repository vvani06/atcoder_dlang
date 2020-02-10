import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;
import std.typecons;

void main() {
  auto M = readln.chomp.to!int;

  long keta;
  long digits_mul;
  long digits_keta;
  foreach(n; 0..M) {
	long d, c; readf("%d %d\n", &d, &c);
	keta += c;
	digits_mul += c * d;
  }
  writeln(keta - 1 + (digits_mul - 1)/9);
}
