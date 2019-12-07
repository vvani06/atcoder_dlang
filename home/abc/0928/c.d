import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  auto N = readln.chomp.to!int;
  auto An = readln.split.to!(int[]);

  int[][] indexedList;
  for(int i=0; i<N; i++) {
    indexedList ~= [i+1, An[i]];
  }
  auto indexedListHeap = indexedList.heapify!"a[1] > b[1]";
  int[] answer;
  foreach(i; 1..N+1) {
    answer ~= indexedListHeap.front[0];
    indexedListHeap.removeFront();
  }

  writeln(answer.to!(string[]).join(" "));
}
