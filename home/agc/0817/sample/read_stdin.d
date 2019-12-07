import std.stdio, std.conv, std.array, std.string;
import std.algorithm;

void main() {
  // 単一の場合
  auto Na = readln.chomp.to!int;
  auto Nb = readln.chomp.to!long;
  
   // intの配列に変換
  auto Ns = readln.split.to!(int[]);

  // 複数の場合
  int a, b;
  readf("%d %d\n", &a, &b);
}
