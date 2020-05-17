void main() {
  problem();
}

void problem() {
  const N = scan!int;
  const K = scan!long;
  const A = scan!int(N);

  int solve() {
    int[int] visited;
    int[] stack = new int[N];

    {
      int next = A[0];
      foreach(i; 0..N) {
        if (i == K - 1) return next;

        stack[i] = next;
        visited[next] = i;
        next = A[next - 1];

        if (next in visited) {
          stack.length = i + 1;
          break;
        }
      }
    }

    const loopBackIndex = visited[A[stack.back - 1]];
    const loopSize = stack.length - loopBackIndex;
    const loopStep = (K - stack.length - 1) % loopSize;
    return stack[loopBackIndex..$][loopStep];
  }

  solve.writeln();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
import std.bigint, std.functional;

// -----------------------------------------------
