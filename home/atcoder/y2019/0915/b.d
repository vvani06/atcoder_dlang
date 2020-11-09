import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;

void main() {
  auto S = readln.chomp;
  auto easy = true;

  for(int i=0; i<S.length; i++) {
    if (i%2 == 0 && S[i] == 'L') easy = false;
    if (i%2 == 1 && S[i] == 'R') easy = false;
  }
  
  writeln(easy ? "Yes" : "No");
}
