void main() {
  problem();
}

void problem() {
  auto X = scan!real;
  auto Y = scan!real;
  auto R = scan!real;

  auto solve() {
    long ans;
    real DR = R*R;

    foreach(real y; (Y-R).ceil..(Y+R).floor+1) {
      const rest = DR - (y - Y).pow(2);
      if (rest < 0) continue;
      if (rest.approxEqual(0) && (X.approxEqual(X.floor))) {
        ans++;
        continue;
      }
      
      const x = rest.sqrt;
      const u = (X + x).floor;
      const l = (X - x).ceil;
      ans += u - l + 1;
    }

    return ans;
  }

  solve().writeln;
}

// ----------------------------------------------

enum EPS = 1e-10;
import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias City = Tuple!(long, "a", long, "t");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
