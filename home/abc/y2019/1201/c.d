import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;

void main() {
  const MAX = 1000000;
  auto budget = readln.chomp.to!int;
  auto hasuu = budget % 100;

  int purchasedCount;
  while(hasuu > 0) {
    if (hasuu < 5) {
      purchasedCount++;
      break;
    }

    purchasedCount++;
    hasuu -= 5;
  }
  
  writeln(purchasedCount*100 <= budget ? "1" : "0");
}
