import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }


class PanaNumber {
  static int SIZE;
  static const DIV = [1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000];
  static int max() {
    int max_number;
    int dec = 1;
    foreach(i; 0..SIZE-1) {
      max_number += dec * (SIZE - i - 1);
      dec *= 10;
    }
    return max_number;
  }

  private int number;
  private int size;
  private bool[] pattern;
  
  this(int i) {
    number = i;
    size = decimal(i);
    pattern = calcPattern(i);
    debug number.writeln;
    debug pattern.writeln;
  }

  int decimal(int i) {
    int dec;
    for(dec = 1; i >= 10; i /= 10) { dec++; }
    return dec;
  }

  bool isEquival(int other) {
    if (size != decimal(other)) return false;
    
    int index;
    foreach(i, div1; DIV[0..SIZE-1]) {
      foreach(div2; DIV[i+1..SIZE]) {
        const ni = (other / div1) % 10;
        const nj = (other / div2) % 10;
        if (pattern[index++] != (ni == nj)) return false;
      }
    }
    return true;
  }

  bool[] calcPattern(int num) {
    bool[] calced = new bool[SIZE*(SIZE-1)/2];
    int index;
    foreach(i, div1; DIV[0..SIZE-1]) {
      foreach(div2; DIV[i+1..SIZE]) {
        const ni = (number / div1) % 10;
        const nj = (number / div2) % 10;
        calced[index++] = ni == nj;
      }
    }
    return calced;
  }

  override string toString() {
    auto chars = new char[SIZE];
    int num = number;
    foreach(i; 0..SIZE) {
      chars[SIZE - i - 1] = cast(char)('a' + (num % 10));
      num /= 10;
    }

    return cast(string)chars;
  }
}

void main() {
  const N = readln.chomp.to!int;
  PanaNumber.SIZE = N;
  
  PanaNumber[] standardPanaNumbers;
  void solve() {
    foreach(i; 0..PanaNumber.max+1) {
      if (standardPanaNumbers.any!(p => p.isEquival(i))) continue;

      standardPanaNumbers ~= new PanaNumber(i);
    }

    standardPanaNumbers.to!(string[]).joiner("\n").writeln;
  }

  solve();
}
