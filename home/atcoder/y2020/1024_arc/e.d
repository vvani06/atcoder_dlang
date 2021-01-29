void main() {
  problem();
}

void problem() {
  const N = scan!long;
  const X = scan!long;
  const M = scan!long;

  void solve() {
    long ans = X;
    long prev = X;
    Step[long] steps;

    for(long i = 1; i < N; i++) {
      if (prev in steps) {
        const loopBack = steps[prev];

        const loopSize = i - loopBack.count;
        const cycle = (N - i) / loopSize;
        i += cycle * loopSize;
        ans += cycle * (ans - loopBack.value);
      }

      if (i == N) break;

      steps[prev] = Step(i, ans);
      prev = prev^^2 % M;
      ans += prev;
    }

    ans.writeln;
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Step = Tuple!(long, "count", long, "value");
ulong MOD = 10^^9 + 7;

// -----------------------------------------------
