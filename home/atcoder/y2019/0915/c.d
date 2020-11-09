import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  int N, K, Q; readf("%d %d %d\n", &N, &K, &Q);
  auto Pn = new int[N];

  for(int i=0; i<Q; i++) {
    auto A = readln.chomp.to!int;
    Pn[A-1]++;
  }
  debug writeln(Pn);
  foreach(P; Pn) writeln(P > Q-K ? "Yes" : "No");
}
