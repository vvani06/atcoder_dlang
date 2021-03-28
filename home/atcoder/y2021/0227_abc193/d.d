void main() {
  problem();
}

void problem() {
  auto K = scan!long;
  auto S = scan[0..4].map!(c => c - '0').array;
  auto T = scan[0..4].map!(c => c - '0').array;

  auto solve() {
    long allZaiko = K*9 - 8;
    long[long] zaiko;
    long[long] ta;
    long[long] ao;
    foreach(i; 0..10) {
      ta[i] = 0;
      ao[i] = 0;
      zaiko[i] = K;
    }

    foreach(i; 0..4) {
      ta[S[i]]++;
      ao[T[i]]++;
      zaiko[S[i]]--;
      zaiko[T[i]]--;
    }

    long score(long[long] cards, long add) {
      long ret;
      foreach(i; 1..10) {
        ret += i * 10^^(cards[i] + (add == i ? 1 : 0));
      }

      return ret;
    }
    score(ta, 0).deb;
    score(ao, 0).deb;

    real divisor = allZaiko * (allZaiko - 1);
    real ans = 0;
    foreach(t; 1..10) {
      if (zaiko[t] <= 0) continue;

      long oppT = zaiko[t];
      auto scoreT = score(ta, t);
      zaiko[t]--;

      foreach(a; 1..10) {
        auto scoreA = score(ao, a);
        if (scoreT <= scoreA) continue;

        long oppA = zaiko[a];
        ans += cast(real)(oppT * oppA) / divisor;
      }
      zaiko[t]++;
    }

    writefln("%0.16f", ans);
  }

  static if (is(ReturnType!(solve) == void)) solve(); else solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
