void main() {
  problem();
}

void problem() {
  enum MAX = 10_000;
  enum MIN = 0;
  alias Desire = Tuple!(long, "x", long, "y", long, "s");
  alias Ad = Tuple!(long, "sx", long, "sy", long, "ex", long, "ey");

  long[] minimumDistances(Desire[] desires) {
    auto ret = new long[](desires.length);
    ret[] = long.max;

    foreach(i; 0..desires.length-1) {
      foreach(j; i+1..desires.length) {
        real d = (desires[i].x - desires[j].x)^^2 + (desires[i].y - desires[j].y) ^^ 2;
        long ld = d.sqrt.to!long;
        ret[i] = ret[i].min(ld);
        ret[j] = ret[j].min(ld);
      }
    }

    return ret;
  }

  Ad[] solve(Desire[] desires) {
    auto ads = desires.map!(d => Ad(d.x, d.y, d.x, d.y)).array;
    auto distances = minimumDistances(desires);

    foreach(i, d; distances) {
      auto r = cast(real)(d / 2) / 2f.sqrt;
      long l = r.to!long;

      ads[i].sx = max(MIN, ads[i].sx - l);
      ads[i].ex = min(MAX, ads[i].ex + l);
      ads[i].sy = max(MIN, ads[i].sy - l);
      ads[i].ey = min(MAX, ads[i].ey + l);
    }

    return ads;
  }

  long calculate(Desire[] desires, Ad[] ads) {
    enum real GETA = 10^^9;
    long ans;
    foreach(i; 0..desires.length) {
      auto d = desires[i];
      auto a = ads[i];
      if (a.sx > d.x || a.ex <= d.x || a.sy > d.y || a.ey <= d.y) continue;

      real seg = (a.ex - a.sx) * (a.ey - a.sy);
      real des = d.s;
      real ratio = 1.to!real - min(des, seg) / max(des, seg);
      ans += (GETA * (1.to!real - ratio.pow(2))).to!long;
    }

    return (ans / desires.length).to!long;
  }

  auto N = scan!long;
  auto desires = N.iota.map!(i => Desire(scan!long, scan!long, scan!long)).array;
  auto ads = solve(desires);

  debug "========================= OUTPUT =========================".deb;
  foreach(a; ads) {
    writefln("%s %s %s %s", a.sx, a.sy, a.ex, a.ey);
  }
  debug "========================= SCORE ==========================".deb;
  debug calculate(desires, ads).deb;
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
