import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  int N, L; readf("%d %d\n", &N, &L);
  string[] Sn = new string[N];
  foreach(i; 0..N) {
    Sn[i] = readln.chomp;
  }
  Sn.sort.joiner.writeln;
}
