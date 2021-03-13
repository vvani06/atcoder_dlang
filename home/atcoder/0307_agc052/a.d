void main() {
  problem();
}

void problem() {

  string lcs(string A, string B) {
    auto t = new long[][](A.length, B.length);

    long l;
    foreach(i; 0..min(A.length, B.length)) {
      bool prev, increased;
      char c = A[i];
      foreach(x, b; B[i..$]) {
        prev |= c == b;
        increased |= prev;
        t[i][x + i] = l + (prev ? 1 : 0);
      }

      prev = false;
      c = B[i];
      foreach(y, a; A[i..$]) {
        prev |= c == a;
        increased |= prev;
        t[y + i][i] = l + (prev ? 1 : 0);
      }

      if (increased) l++;
    }

    long y = A.length - 1;
    long x = B.length - 1;
    auto v = t[y][x]; 
    char[] ret;
    r: while(t[y][x] >= 1) {
      v.deb;
      ret = B[x] ~ ret;
      if (v-- == 1) break;
      if (--x == 0) break;

      while(--y >= 0) {
        foreach(tx; 0..x) {
          if (t[y][x - tx] == v) {
            x -= tx;
            continue r;
          }
        }
      }

      break;
    }

    t.deb;
    ret.deb;

    return ret.to!string;
  }

  string subSolve(long N, string[] S) {
    return lcs(S[0] ~ S[0], S[1] ~ S[1]);
  }

  auto solve() {
    foreach(_; 0..scan!long) {
      subSolve(scan!long, scan!string(3)).writeln;
    }
  }

  static if (is(ReturnType!(solve) == void)) solve(); else solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time;
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
