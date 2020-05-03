void main() {
  problem();
}

void problem() {
  const N = scan!long;
  const S = scan;

  long solve() {
    long ans;

    const totalR = S.count('R');
    const totalG = S.count('G');
    const totalB = S.count('B');

    long[] R = new long[N];
    long[] G = new long[N];
    long[] B = new long[N];

    int countR, countG, countB;
    foreach(i; 0..N) {
      R[i] = totalR - countR;
      G[i] = totalG - countG;
      B[i] = totalB - countB;
      if (S[i] == 'R') countR++;
      if (S[i] == 'G') countG++;
      if (S[i] == 'B') countB++;
    }
    
    long[][char] RGB;
    RGB['R'] = R;
    RGB['G'] = G;
    RGB['B'] = B;

    char[][char] OTHERS;
    OTHERS['R'] = ['G', 'B'];
    OTHERS['G'] = ['R', 'B'];
    OTHERS['B'] = ['R', 'G'];

    foreach(i; 0..N-2) {
      const c1 = S[i];
      foreach(j; i+1..N-1) {
        const spread = j - i;
        const c2 = S[j];
        if (c1 == c2) continue;

        const others = OTHERS[c1];
        const c3 = others[0] == c2 ? others[1] : others[0];
        // [c1, c2, c3].deb;

        RGB[c3][j+1].deb;
        ans += RGB[c3][j+1];
        if (j + spread < N && S[j + spread] == c3) {
          [i, j, j + spread].deb;
          [S[i], S[j], S[j + spread]].deb;
          ans--;
        }
      }
    }

    return ans;
  }

  solve().writeln;
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
