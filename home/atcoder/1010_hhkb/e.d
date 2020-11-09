void main() {
  problem();
}

void problem() {
  const H = scan!long;
  const W = scan!long;
  const S = H.iota.map!(_ => scan.map!(c => c == '.').array ~ false).array ~ (W+1).iota.map!(_ => false).array;

  void solve() {

    int[][] around;
    around.length = H;
    foreach(i; 0..H) around[i] = new int[W];
    ulong K;
    
    foreach(y; 0..H) {
      int con;
      foreach(x; 0..W) if (!S[y][x]) { con = 0; } else { K++; around[y][x] += con++; }
      con = 0;
      foreach_reverse(x; 0..W) if (!S[y][x]) { con = 0; } else { around[y][x] += con++; }
    }
    foreach(x; 0..W) {
      int con;
      foreach(y; 0..H) if (!S[y][x]) { con = 0; } else { around[y][x] += con++; }
      con = 0;
      foreach_reverse(y; 0..H) if (!S[y][x]) { con = 0; } else { around[y][x] += con++; }
    }

    debug {
      K.deb;
      around.deb;
    }
    
    long total = powmod(2UL, K, MOD);
    total = (K*total) % MOD;

    auto memo2PowMod = new long[K];
    {
      long pm = 1;
      foreach(i; 0..K) {
        memo2PowMod[$-1-i] = pm;
        pm = (pm * 2) % MOD;
      }
    }

    memo2PowMod.deb;

    long removal;
    foreach(y; 0..H) {
      foreach(x; 0..W) {
        if (!S[y][x]) continue;

        long comb = memo2PowMod[around[y][x]];
        comb.deb;
        removal = (removal + comb) % MOD;
      }
    }

    [total, removal].deb;
    
    long ans = total - removal;
    if (ans < 0) ans += MOD;
    
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
alias Point = Tuple!(long, "x", long, "y");
ulong MOD = 10^^9 + 7;

// -----------------------------------------------
