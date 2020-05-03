void main() {
  problem();
}

void problem() {
  const X = scan!int;
  const Y = scan!int;
  const A = scan!int;
  const B = scan!int;
  const C = scan!int;
  auto P = scan!long(A).sort!"a > b".array;
  auto Q = scan!long(B).sort!"a > b".array;
  auto R = scan!long(C);
  
  deb([X, Y, A, B, C]);
  deb(P);deb(Q);deb(R);

  long solve() {

    auto apples = (P[0..X] ~ Q[0..Y] ~ R).sort!"a > b".array;
    return apples[0..X+Y].sum;

    auto replacable = X + Y <= C ? X + Y : C;
    auto red_border = X - 1;
    auto green_border = Y - 1;

    auto red_sum = P[0..X].sum;
    auto green_sum = Q[0..Y].sum;

    foreach(r; R[0..replacable]) {
      long red_value = red_border >= 0 ? P[red_border] : 0;
      long green_value = green_border >= 0 ? Q[green_border] : 0;

      if (red_value == 0 && green_value == 0) break;

      if (red_value < green_value && r > P[red_border]) {
        red_sum += r - P[red_border];
        red_border--;
      }
      if (green_value < red_value && r > Q[green_border]) {
        green_sum += r - Q[green_border];
        green_border--;
      }

      break;
    }

    deb(red_sum);
    deb(green_sum);

    return red_sum + green_sum;
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
