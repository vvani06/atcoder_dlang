import std.stdio, std.conv, std.array, std.string;
import std.algorithm;

void main() {
  string s = readln.chomp;

  string prev;
  uint count = 0;
  auto n = s.length;
  for(uint i=0; i<n; i++) {
    if (s[i..i+1] == prev) {
      if (i+1 == n) break;
      prev = s[i..i+2];
      count++;
      i++;
      continue;
    }
    prev = s[i..i+1];
    count++;
  }

  writeln(count);
}
