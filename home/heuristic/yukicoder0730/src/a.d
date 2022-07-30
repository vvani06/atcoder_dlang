void main() { runSolver(); }

// ----------------------------------------------

enum long ALPHA = 5;
enum ALPHAS = [0, 0, ALPHA^^2, ALPHA, 1];

alias Vector = Vector2!long;

struct Spot {
  int type, id;
  Vector location;

  long energy(Spot other) {
    auto k = ALPHAS[type + other.type];
    return location.norm(other.location) * k;
  }

  string toString() {
    return "%s %s".format(type, id);
  }
}
enum long BOUNDARY = 10 ^^ 3;

Vector center(Vector[] arr) {
  long x = arr.map!"a.x".sum / arr.length;
  long y = arr.map!"a.y".sum / arr.length;
  return Vector(x, y);
}

Vector center(Spot[] arr) {
  long x = arr.map!"a.location.x".sum / arr.length;
  long y = arr.map!"a.location.y".sum / arr.length;
  return Vector(x, y);
}

auto degComp(Spot as, Spot bs, Vector center) {
  auto a = as.location;
  auto b = bs.location;
  auto d1 = atan2(a.y.to!real - center.y.to!real, a.x.to!real - center.x.to!real);
  auto d2 = atan2(b.y.to!real - center.y.to!real, b.x.to!real - center.x.to!real);
  return d1 < d2;
}

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto P = N.iota.map!(_ => Vector(scan!long, scan!long)).array;
  auto rnd = Xorshift(unpredictableSeed);

  auto solve() {
    auto allCenter = center(P);
    auto targets = P.enumerate(1).map!(p => Spot(1, p[0], p[1])).array;

    targets.sort!((a, b) => degComp(a, b, allCenter));
    auto startIndex = targets.countUntil!(t => t.id == 1);
    targets = targets[startIndex..$] ~ targets[0..startIndex];

    auto stationIndicies = 0 ~ iota(1, M + 1).map!(m => N * m / M).array;
    auto stations = M.iota.map!(i => Spot(2, i + 1, center(targets[stationIndicies[i]..stationIndicies[i + 1]])));

    Spot[] routes;
    routes ~= targets[0];
    foreach(si; 0..M) {
      foreach(i; stationIndicies[si]..stationIndicies[si + 1]) {
        auto d1 = routes[$ - 1].energy(stations[si]) + stations[si].energy(targets[i]);
        auto d2 = routes[$ - 1].energy(targets[i]);
        if (d1 < d2) {
          routes ~= stations[si];
          routes ~= targets[i];
        } else {
          routes ~= targets[i];
        }
      }
      routes ~= stations[si];
    }
    routes ~= targets[0];

    auto ri = iota(1, routes.length - 1).array;
    foreach(i; 0..10^^6) {
      auto a = ri.choice(rnd);
      auto b = ri.choice(rnd);

      auto efa = routes[a - 1].energy(routes[a]) + routes[a].energy(routes[a + 1]);
      auto efb = routes[b - 1].energy(routes[b]) + routes[b].energy(routes[b + 1]);
      auto eta = routes[a - 1].energy(routes[b]) + routes[b].energy(routes[a + 1]);
      auto etb = routes[b - 1].energy(routes[a]) + routes[a].energy(routes[b + 1]);

      if (efa + efb > eta + etb) swap(routes[a], routes[b]);
    }

    Spot[] filtered;
    filtered ~= routes[0];
    routes = routes.uniq.array;
    foreach(i; 1..routes.length - 1) {
      if (routes[i - 1..i + 1].all!(s => s.type == 2)) {
        if (routes[i - 1].id == routes[i + 1].id) continue;
      }

      filtered ~= routes[i];
    }
    filtered ~= routes[$ - 1];
    routes = filtered;

    long energy;
    foreach(i; 0..routes.length - 1) {
      energy += routes[i].energy(routes[i + 1]);
    }
    stderr.writeln(10L^^9 / (1000 + energy.to!real.sqrt));

    string[] ans;
    foreach(s; stations) ans ~= s.location.toString;
    ans ~= routes.length.to!string;
    ans ~= routes.map!"a.toString".array;

    return ans;
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
T[] divisors(T)(T n) { T[] ret; for (T i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == float) || is(T == double) || is(T == real)) "%.16f".writefln(fn());
  else static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
  else static if (isInputRange!T) {
    static if (!is(string == ElementType!T) && isInputRange!(ElementType!T)) foreach(r; fn()) r.toAnswerString.writeln;
    else foreach(r; fn()) r.writeln;
  }
  else fn().writeln;
}
void runSolver() {
  enum BORDER = "#==================================";
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

struct Vector2(T) {
  T x, y;
  Vector2 add(Vector2 other) { return Vector2(x + other.x, y + other.y ); }
  Vector2 opAdd(Vector2 other) { return add(other); }
  Vector2 sub(Vector2 other) { return Vector2(x - other.x, y - other.y ); }
  Vector2 opSub(Vector2 other) { return sub(other); }
  T norm(Vector2 other) {return (x - other.x)*(x - other.x) + (y - other.y)*(y - other.y); }
  T dot(Vector2 other) {return x*other.y - y*other.x; }
  Vector2 normalize() {if (x == 0 || y == 0) return Vector2(x == 0 ? 0 : x/x.abs, y == 0 ? 0 : y/y.abs);const gcd = x.abs.gcd(y.abs);return Vector2(x / gcd, y / gcd);}
  string toString() { return "%s %s".format(x, y); }
}

