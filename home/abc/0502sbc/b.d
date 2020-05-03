void main() {
  problem();
}

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto Q = scan!int;
  auto ABCD = Q.iota.map!(scan!int(4));

  ulong solve() {
    ulong years;
    real money = 100;

    while(money < X) {
      years++;
      money = cast(ulong)(cast(real)money * 1.01);
    }

    return years;
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

import std.concurrency;
 
Generator!(T[]) permutationsWithRepetitions(T)(T[] data, in uint n)
in {
    assert(!data.empty && n > 0);
} body {
    return new typeof(return)({
        if (n == 1) {
            foreach (el; data)
                yield([el]);
        } else {
            foreach (el; data)
                foreach (perm; permutationsWithRepetitions(data, n - 1))
                    yield(el ~ perm);
        }
    });
}

// -----------------------------------------------
