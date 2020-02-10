import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;

void main() {
  auto S = readln.chomp;
  auto T = readln.chomp;
  
  int correct_count = 0;
  for(int i=0; i<S.length; i++) {
    if (S[i] == T[i]) correct_count++;
  }

  writeln(correct_count);
}
