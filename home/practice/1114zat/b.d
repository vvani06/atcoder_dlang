void main() {
  problem();
}

void problem() {
  auto NA = scan!long;
  auto NB = scan!long;
  auto A = scan!long(NA);
  auto B = scan!long(NB);

  void solve() {
    bool[long] words;
    bool[long] dicA;
    foreach(a; A) {
      dicA[a] = true;
      words[a] = true;
    }
    bool[long] dicB;
    foreach(b; B) {
      dicB[b] = true;
      words[b] = true;
    }
    
    long metaOr, metaAnd;
    foreach(i; words.keys) {
      if ((i in dicA) && (i in dicB)) {
        metaAnd++;
      }
      if ((i in dicA) || (i in dicB)){
        metaOr++;
      }
    }

    writefln("%.10f", metaAnd.to!real / metaOr.to!real);
  }

  solve();
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
