void main() {
  problem();
}

void problem() {
  auto S = scan;
  auto L = S.length;

  auto solve() {
    alias Inverter = Tuple!(long, "pos", char, "c");
    DList!Inverter inv;
    foreach(i; 0..L-2) {
      if (S[i] == S[i+1] && S[i] != S[i+2]) {
        inv.insertBack(Inverter(i, S[i]));
      }
    }

    long ans;
    char lastChar = S[$ - 1];
    long lastPos = L;
    while(!inv.empty) {
      const v = inv.back;
      inv.removeBack();
      v.deb;

      long exc = 0;
      foreach(c; S[v.pos+2..lastPos]) {
        if (c == v.c) exc++;
        c.deb;
      }
      long len = lastPos - v.pos - 2;
      ans += lastChar == v.c ? len - exc : (L - lastPos) + len - exc;
      [lastPos, len, ans].deb;
      lastPos = v.pos;
      lastChar = v.c;
    }

    return ans;
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
