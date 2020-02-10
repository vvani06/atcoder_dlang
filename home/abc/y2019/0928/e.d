import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import std.bitmanip;
import std.math;
import std.regex;

class Key {
  public int price;
  public int canOpen;

  this(int price, int[] boxNumbers, int maxBoxSize) {
    this.price = price;
    foreach(i; 1..maxBoxSize+1) if (boxNumbers.canFind(i)) canOpen += 2.pow(i - 1);
  }
}

void main() {
  int N, M; readf("%d %d\n", &N, &M);
  Key[] keys;
  foreach(z; 0..M) {
    int price, canOpenCount; readf("%d %d\n", &price, &canOpenCount);
    keys ~= new Key(price, readln.split.to!(int[]), N);
  }
  
  uint[int] dp;
  int[] updated = [0];
  dp[updated[0]] = 0;

  while(true) {
    int[] nextUpdated;
    foreach(current; updated) {
      foreach(key; keys) {
        int next = current | key.canOpen;
        if (next == current) continue;
        if (next in dp && dp[next] <= dp[current] + key.price) continue;

        dp[next] = dp[current] + key.price;
        nextUpdated ~= next;
      }
    }
    debug nextUpdated.writeln;
    debug dp.writeln;
    if (nextUpdated.empty) break;
    updated = nextUpdated;
  }

  int allOpened = 0;
  N.iota.each!(n => allOpened += 2.pow(n));
  writeln(allOpened in dp ? dp[allOpened].to!string : "-1");
}
