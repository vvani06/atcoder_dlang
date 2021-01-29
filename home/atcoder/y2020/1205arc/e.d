void main() {
  problem();
}

void problem() {
  const W = scan!long;
  const H = scan!long;
  const N = scan!long;
  const M = scan!long;
  auto Lights = N.iota.map!(_ => Point(scan!long - 1, scan!long - 1)).array;
  auto Blocks = M.iota.map!(_ => Point(scan!long - 1, scan!long - 1)).array;

  void solve() {

    bool[][] S;
    foreach(i; 0..H) S ~= new bool[W];

    foreach(b; Blocks) {
      S[b.y][b.x] = true;
    }

    long ans;
    bool[][] calcedY;
    bool[][] calcedX;
    foreach(i; 0..H) calcedY ~= new bool[W];
    foreach(i; 0..H) calcedX ~= new bool[W];

    foreach(l; Lights) {
      if (!calcedY[l.y][l.x]) {
        foreach_reverse(y; 0..l.y) {
          if (S[y][l.x]) break;
          ans++;
          [y, l.x].deb;
          calcedY[y][l.x] = true;
        }
        foreach(y; (l.y + 1)..H) {
          if (S[y][l.x]) break;
          ans++;
          [y, l.x].deb;
          calcedY[y][l.x] = true;
        }
      }
      if (calcedY[l.y][l.x] == false && calcedX[l.y][l.x] == false) ans++;
      calcedY[l.y][l.x] = true;
    }

    foreach(l; Lights) {
      if (!calcedX[l.y][l.x]) {
        foreach_reverse(x; 0..l.x) {
          if (S[l.y][x]) break;
          if (!calcedY[l.y][x] && !calcedX[l.y][x]) ans++;
          [l.y, x].deb;
          calcedX[l.y][x] = true;
        }
        foreach(x; (l.x + 1)..W) {
          if (S[l.y][x]) break;
          if (!calcedY[l.y][x] && !calcedX[l.y][x]) ans++;
          [l.y, x].deb;
          calcedX[l.y][x] = true;
        }
      }
      calcedX[l.y][l.x] = true;
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
alias Point = Tuple!(long, "x", long, "y");
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
