void main() {
  problem();
}

void problem() {
  const H = scan!long;
  const W = scan!long;
  const S = H.iota.map!(_ => scan.map!(c => c == '.').array ~ false).array ~ (W+1).iota.map!(_ => false).array;

  void solve() {

    int[][] conW;
    int[][] conH;
    conW.length = H+1; foreach(y; 0..H+1) conW[y].length = W+1;
    conH.length = H+1; foreach(y; 0..H+1) conH[y].length = W+1;
    ulong K;
    
    foreach(y; 0..H) {
      int con;
      foreach(x; 0..W+1) {
        if (!S[y][x]) {
          foreach(c; 0..con) {
            conW[y][x - c - 1] = con;
          }
          con = 0;
          continue;
        }
        K++;
        con++;
      }
    }
    foreach(x; 0..W) {
      int con;
      foreach(y; 0..H+1) {
        if (!S[y][x]) {
          foreach(c; 0..con) {
            conH[y - c - 1][x] = con;
          }
          con = 0;
          continue;
        }
        con++;
      }
    }

    debug {
      S.deb;
      conW.deb;
      conH.deb;
    }
    
    long total = powmod(2UL, K, MOD);
    total = (K*total) % MOD;

    long removal;
    foreach(y; 0..H) {
      foreach(x; 0..W) {
        if (!S[y][x]) continue;

        long comb = powmod(2UL, (K - (conW[y][x] + conH[y][x] - 1)).to!ulong, MOD);
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
