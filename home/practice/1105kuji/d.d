void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto G = (N - 1).iota.map!(_ => Point(scan!long, scan!long)).array;

  void solve() {
    long[] pathesOnNodes = new long[N + 1];
    bool[long][] pathNumbersOnNodes;
    pathNumbersOnNodes.length = N + 1;

    foreach(i, g; G) {
      pathesOnNodes[g.x]++;
      pathesOnNodes[g.y]++;
      pathNumbersOnNodes[g.x][i] = true;
      pathNumbersOnNodes[g.y][i] = true;
    }

    long K = pathesOnNodes.maxElement;
    K.writeln;

    auto topNode = iota(1, N+1).array.sort!((a, b) => pathesOnNodes[a] > pathesOnNodes[b])[0];
    long[] colors = new long[N - 1];
    bool[long][] usedColor;
    usedColor.length = N + 1;

    auto next = [topNode];
    bool[long] done;
    while(true) {
      long[] nextNext;
      foreach(currentNode; next) {
        done[currentNode] = true;
        long c = 1;
        foreach(path; pathNumbersOnNodes[currentNode].keys) {
          const anotherNode = G[path].x == currentNode ? G[path].y : G[path].x;
          if (!(anotherNode in done)) nextNext ~= anotherNode;
          if (colors[path] != 0) continue;
          while (c in usedColor[currentNode]) {
            c++;
            if (c > K) c = 1;
          }
          colors[path] = c;
          usedColor[currentNode][c] = true;
          usedColor[anotherNode][c] = true;
        }
      }
      next = nextNext;
      nextNext.length = 0;
      if (next.length == 0) break;
    }

    foreach(c; colors) writeln(c);
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
