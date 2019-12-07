import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  int N, M; readf("%d %d\n", &N, &M);
  auto An = readln.split.to!(ulong[]);
  auto discounts = An.map!(a => [a - a/2, a]).array;
  auto discountsHeap = discounts.heapify!"a[0] < b[0]";

  foreach(t; 0..M) {
    auto discounted = discountsHeap.front[1]/2;
    discountsHeap.removeFront();
    discountsHeap.insert([discounted - discounted/2, discounted]);
  }

  discounts.map!(a => a[1]).sum.writeln;
}
