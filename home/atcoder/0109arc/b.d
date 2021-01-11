void main() {
  problem();
}

void problem() {
  auto N = scan!long;
  auto C = N.iota.map!(i => Card(i, scan!long, scan!long)).array;

  void solve() {
    bool[long] used;
    Color[long] colors;
    foreach(c; C) {
      if (c.A == c.B) {
        used[c.identifier] = true;
        colors.require(c.A, Color(c.A, 0, [], true));
        continue;
      }

      foreach(cc; [c.A, c.B]) {
        colors.require(cc, Color(cc, N + 1, [], false));
        colors[cc].rarity--;
        colors[cc].others ~= c;
      }
    }

    long cost(Card card, long value) {
      const other = card.A == value ? card.B : card.A;
      return colors[other].rarity;
    }

    auto heap = heapify!"a.rarity < b.rarity"(colors.values);
    while(!heap.empty) {
      auto color = heap.front;
      heap.removeFront;
      if (colors[color.identifier].used) continue;
      
      foreach(card; color.others.sort!((a, b) => cost(a, color.identifier) < cost(b, color.identifier))) {
        if (card.identifier in used) continue;

        used[card.identifier] = true;
        const other = card.A == color.identifier ? card.B : card.A;
        colors[color.identifier].used = true;
        long baseRarity = colors[color.identifier].rarity;
        colors[color.identifier].rarity = -N;
        colors[other].rarity++;
        if (colors[other].rarity >= baseRarity) heap.insert(colors[other]);

        color.identifier.deb;
        card.deb;
        colors[color.identifier].deb;
        break;
      }
    }

    colors.values.count!"a.used == true".writeln;
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
alias Card = Tuple!(long, "identifier", long, "A", long, "B");
alias Color = Tuple!(long, "identifier", long, "rarity", Card[], "others", bool, "used");
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
