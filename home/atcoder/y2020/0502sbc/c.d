void main() {
  problem();
}

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto Q = scan!int;
  auto ABCD = Q.iota.map!(x => scan!int(4)).array;

  long calcScore(int[] nm) {
    
    long s;
    foreach(abcd; ABCD) {
      auto a = abcd[0];
      auto b = abcd[1];
      auto c = abcd[2];
      auto d = abcd[3];

      if (nm[b] - nm[a] == c) s += d;
    }

    nm.deb;

    return s;
  }

  long solve() {
    int[] numbers = new int[N + 1];
    numbers[] = 1;
    numbers[$-1] = 0;

    long max_score;
    while(true) {

      foreach_reverse(right; 1..N+1) {
        if (numbers[right] == M) continue;

        numbers[right..$] = numbers[right] + 1;
        break;
      }
      
      long score = calcScore(numbers);
      if (score > max_score) max_score = score;
      
      if (numbers[1] == M) break;
    }

    return max_score;
  }

  writeln(solve());
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
