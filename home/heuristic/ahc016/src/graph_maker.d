struct Graph {
  string sourceString;
  int size;
  bool[] edges;
  int[] dg;

  static int triangle(int k) { return k * (k - 1) / 2; }

  this(string s) {
    sourceString = s;
    edges = s.map!(c => c == '1').array;
    const l = s.length;
    foreach(i; 4..101) {
      if (triangle(i) == l) {
        size = i;
        break;
      }
    }
  }

  this(int size) {
    this(triangle(size).iota.map!(_ => cast(dchar)('0' + uniform(0, 2))).to!string);
  }

  int[] degrees() {
    if (!dg.empty) return dg;

    auto ret = new int[](size);
    const base = triangle(size);
    foreach(i; 0..size - 1) {
      const offset = base - triangle(size - i);
      foreach(j; i + 1..size) {
        if (edges[offset + j - i - 1]) {
          ret[i]++;
          ret[j]++;
        }
      }
    }

    ret.sort;
    return dg = ret;
  }

  Graph simulate(real r) {
    string s;
    foreach(c; sourceString) {
      auto rand = uniform(0.0f, 1.0f);
      if (rand < r) {
        s ~= c == '0' ? '1' : '0';
      } else {
        s ~= c;
      }
    }
    return Graph(s);
  }

  long distance(Graph other) {
    long ret;
    foreach(a, b; zip(degrees, other.degrees)) {
      ret += (a - b) ^^ 2;
    }

    return ret;
  }

  string toString() {
    return sourceString;
  }
}

void main() {
  foreach(graphSize; [16, 24, 32, 40, 48]) {
    foreach(M; 10..101) {
      Graph[] graphs;
      graphs ~= Graph('0'.repeat(Graph.triangle(graphSize)).to!string);
      graphs ~= Graph('1'.repeat(Graph.triangle(graphSize)).to!string);
      foreach(_; 2..M) {
        Graph best;
        long bestScore;
        foreach(t; 0..5000) {
          auto c = Graph(graphSize);
          auto minDistance = graphs.map!(g => g.distance(c)).minElement;
          if (bestScore.chmax(minDistance)) best = c;
        }
        graphs ~= best;
      }
      graphs.map!"a.sourceString".joiner(",").to!string.writeln;
    }

  }
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

// -----------------------------------------------
