void main() {
  problem();
}

void problem() {
  auto N = scan!int;
  auto A = scan!long(N);
  auto Q = scan!int;
  auto Queues = Q.iota.map!(x => Queue(scan!long, scan!long)).array;

  void solve() {
    long[long] nums;
    long summary;
    foreach(a; A) {
      nums[a]++;
      summary += a;
    }

    foreach(q; Queues) {
      if (q.from in nums) {
        nums[q.to] += nums[q.from];
        summary += (q.to - q.from) * nums[q.from];
        nums.remove(q.from);
      }
      writeln(summary);
    }

    return;
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
alias Queue = Tuple!(long, "from", long, "to");

// -----------------------------------------------
