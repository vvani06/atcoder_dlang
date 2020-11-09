void main() {
  problem();
}

void problem() {
  const N = scan!int;
  const An = scan!long(N);

  long solve() {
    bool[int] candidates;
    foreach(i; 0..N) candidates[i] = false;

    long answer;
    foreach(i; 0..N) {
      long maxJoy = -1;
      int maxJoyIndex;
      foreach(j; candidates.keys) {
        const joy = An[j] * std.math.abs(j - i);
        if (maxJoy < joy) {
          maxJoy = joy;
          maxJoyIndex = j;
        }
      }
      candidates.remove(maxJoyIndex);
      deb([i, maxJoy, maxJoyIndex]);
      answer += maxJoy;
    }

    return answer;
  }

  long solve2() {

    foreach(perm; 12.iota.permutations){
    }

    return 0;
  }

  solve2().writeln;
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
