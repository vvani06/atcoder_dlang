void main() {
  SysTime[string] watched;
  auto files = ["a","b","c","d","e","f"].map!(pg => [[pg, pg~".d"], [pg, "input/"~pg]]).array.joiner;
  foreach(f; files) {
    if (f[1].exists) watched[f[1]] = f[1].timeLastModified;
  }

  auto build(string pg) {
    spawnShell("clear", std.stdio.stdin, std.stdio.stdout);
    return spawnShell("echo BUILD "~pg~"; dmd -debug -of/tmp/"~pg~"_out "~pg~".d && /tmp/"~pg~"_out < input/"~pg, std.stdio.stdin, std.stdio.stdout);
  }

  auto task = build("a");
  while(true) {
    Thread.sleep( dur!("msecs")( 100 ) );
    foreach(f; files) {
      if (!f[1].exists) continue;

      const t = f[1].timeLastModified;
      if (watched[f[1]] != t) {
        watched[f[1]] = t;
        kill(task);
        task = build(f[0]);
      }
    }
  }
}

// ----------------------------------------------

import std.file;
import std.datetime;
import core.thread, std.process;
import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.functional, core.bitop;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
