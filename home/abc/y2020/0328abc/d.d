void main() {
  problem();
}

void problem() {
  const N = scan!int;
  const X = scan!int;
  const Y = scan!int;

  void solve() {
    int[int] counts;

    foreach(i; 1..N) {
      foreach(j; i+1..N+1) {
        auto liner = j - i;
        auto linerIToX = X - i;
        if (linerIToX < 0) linerIToX *= -1;

        auto winded = j - Y;
        if (winded < 0) winded *= -1;
        winded += linerIToX + 1;

        deb([i, j, liner, winded]);

        auto distance = min(liner, winded);
        counts[distance]++;
      }
    }
    
    foreach(i; 1..N) {
      writeln(i in counts ? counts[i] : 0);
    }
  }

  void solveBfs() {
    int[int][int] all;
    alias Queue = Tuple!(int, "num", int, "step");

    foreach(i; 1..N) {
      int[int] distances;
      auto queues = [Queue(i, 0)];

      while(queues.length > 0) {
        Queue[] next_queues;

        foreach(q; queues) {
          int[] candidates;
          if (q.num > 1) candidates ~= q.num - 1;
          if (q.num < N) candidates ~= q.num + 1;
          if (q.num == X) candidates ~= Y;
          if (q.num == Y) candidates ~= X;
          auto nextStep = q.step + 1;
          
          foreach(c; candidates) {
            if (!(c in distances) || distances[c] > nextStep) {
              next_queues ~= Queue(c, nextStep);
              distances[c] = nextStep;
            }
          }
        }

        queues = next_queues;
      }
      all[i] = distances;
      deb(distances);
    }

    int[int] counts;
    foreach(i; 1..N) {
      foreach(j; i+1..N+1) {
        counts[all[i][j]]++;
      }
    }

    deb(counts);
    foreach(i; 1..N) {
      writeln(i in counts ? counts[i] : 0);
    }
  }

  solveBfs();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
