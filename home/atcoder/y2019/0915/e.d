import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;
import std.math;
import std.regex;

void main() {
  auto N = readln.chomp.to!int;
  auto S = readln.chomp;
  auto Ln = new int[N];

  Ln[0] = 1;
  int i = 1, j = 0;
  while (i < N) {
    while (i+j < N && S[j] == S[i+j]) ++j;
    Ln[i] = j;
    if (j == 0) { ++i; continue;}
    int k = 1;
    while (i+k < N && k+Ln[k] < j) Ln[i+k] = Ln[k], ++k;
    i += k; j -= k;
  }

  Ln.writeln;
}

// aaabaaaab
// 921034210