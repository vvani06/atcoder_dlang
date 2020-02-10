import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.numeric;
import std.math;

void main() {
  auto N = readln.chomp.to!int;
  auto Ln = readln.split.to!(int[]).sort;

  auto sizes = new int[1002];
  int count = 0;
  auto last = reduce!(delegate(int a, int b){
    foreach(i; a..b) sizes[i+1] = count;
    count++;
    return b;
  })(0, Ln);
  foreach(i; last..1001) sizes[i+1] = count;
  debug writeln(sizes);

  int total = 0;
  foreach(j; 1..N-1) {
    auto b = Ln[j];
    for(int i=0; i<j; i++) {
      auto a = Ln[i];
      total += sizes[a+b > 1001 ? 1001 : a+b] - j - 1;
    }
  }

  writeln(total);
}
