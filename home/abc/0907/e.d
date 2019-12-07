import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container, std.range;

void main() {
  auto N = readln.chomp.to!int;
  auto Pn = readln.split.to!(int[]);
  auto In = new int[N+1];
  iota(N).each!(i => In[Pn[i]] = i);

  writeln(In);
}
