void main()
{
  problem();
}

void problem()
{
  const N = scan!int;
  const M = scan!int;
  const Pathes = M.iota
    .map!(_ => scan!int(2))
    .array;
  
  int[][] Routes;
  Routes.length = N;
  foreach(p; Pathes) {
    Routes[p[0] - 1] ~= p[1] - 1;
    Routes[p[1] - 1] ~= p[0] - 1;
  }

  Routes.deb;

  void solve()
  {
    int[] distances = new int[N];
    int[] previousNode = new int[N];

    {
      int[] queue = [0];
      int distance;
      int visitedCount;

      distances[] = -1;
      distances[0] = 0;
      while(true) {
        bool changed;
        distance++;

        queue.deb;
        foreach(from; queue[visitedCount..$]) {
          visitedCount++;
          Routes[from].deb;

          foreach(next; Routes[from]) {
            if (distances[next] != -1) continue;

            distances[next] = distance;
            previousNode[next] = from;
            queue ~= next;
            changed = true;
          }
        }

        if (!changed) break;
      }
    }

    distances.deb;
    previousNode.deb;

    writeln("Yes");
    foreach(n; previousNode[1..$]) {
      writeln(n + 1);
    }
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm,
  std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;

T[][] combinations(T)(T[] s, in int m)
{
  if (!m)
    return [[]];
  if (s.empty)
    return [];
  return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m);
}

string scan()
{
  static string[] ss;
  while (!ss.length)
    ss = readln.chomp.split;
  string res = ss[0];
  ss.popFront;
  return res;
}

T scan(T)()
{
  return scan.to!T;
}

T[] scan(T)(int n)
{
  return n.iota.map!(i => scan!T()).array;
}

void deb(T...)(T t)
{
  debug writeln(t);
}

alias Point = Tuple!(long, "x", long, "y");
import std.bigint, std.functional;

// -----------------------------------------------
