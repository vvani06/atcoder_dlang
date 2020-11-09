void main() {
  problem();
}

class Route {
  long cost;
  long duration;
  Station from;
  Station to;

  this(long stationIdentifierFrom, long stationIdentifierTo, long cost, long duration) {
    this.cost = cost;
    this.duration = duration;
    this.from = Station.find(stationIdentifierFrom);
    this.to = Station.find(stationIdentifierTo);
    this.from.routes ~= this;
    this.to.routes ~= this;
  }
}

class Station {
  static long nextIdentifier;
  static Station[] stations;

  static Station find(long identifier) {
    foreach(s; Station.stations) {
      if (s.identifier == identifier) return s;
    }

    throw new Exception("no station");
  }

  long identifier;
  long exchangeSize;
  long exchangeDuration;
  Route[] routes;

  this(long exchangeSize, long exchangeDuration) {
    this.exchangeSize = exchangeSize;
    this.exchangeDuration = exchangeDuration;
    this.identifier = ++Station.nextIdentifier;
    Station.stations ~= this;
  }
}

void problem() {
  const N = scan!long;
  const M = scan!long;
  const S = scan!long;

  const ROUTES = M.iota.map!(_ => scan!long(4)).array;

  foreach(_; 0..N) {
    const s = scan!long(2);
    new Station(s[0], s[1]);
  }
  ROUTES.each!(r => new Route(r[0], r[1], r[2], r[3]));

  void solve() {
    const source = Station.find(1);
    foreach(destinationStationIdentifier; 2..N+1) {
      const destination = Station.find(destinationStationIdentifier);
    }

  }
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
