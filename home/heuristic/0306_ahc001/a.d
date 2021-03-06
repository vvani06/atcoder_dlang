void main() {
  problem();
}

void problem() {
  alias Desire = Tuple!(long, "x", long, "y", long, "s");
  alias Ad = Tuple!(long, "sx", long, "sy", long, "ex", long, "ey");
  enum real GETA = 10^^9;

  Ad[] solve(Desire[] desires) {
    return Ad(0, 0, 10000, 10000).repeat(desires.length).array;
  }

  long calculate(Desire[] desires, Ad[] ads) {
    long ans;
    foreach(i; 0..desires.length) {
      auto d = desires[i];
      auto a = ads[i];
      if (a.sx > d.x || a.ex < d.x || a.sy > d.y || a.ey < d.y) continue;

      real seg = (a.ex - a.sx) * (a.ey - a.sy);
      real des = d.s;
      real ratio = 1.to!real - min(des, seg) / max(des, seg);
      ans += GETA * (1.to!real - ratio.pow(2));
    }

    return (ans / desires.length).to!long;
  }

  auto N = scan!long;
  auto desires = N.iota.map!(i => Desire(scan!long, scan!long, scan!long)).array;
  auto ads = solve(desires);

  debug {
    calculate(desires, ads).deb;
  }
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
