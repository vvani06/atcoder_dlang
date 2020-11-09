void main() {
  problem();
}

struct Vector2(T) {
  T x, y;

  this(T x, T y) {
    this.x = x;
    this.y = y;
  }

  Vector2 add(Vector2 other) {
    return Vector2(x + other.x, y + other.y);
  }

  Vector2 sub(Vector2 other) {
    return Vector2(x - other.x, y - other.y);
  }

  Vector2 mul(T t) {
    return Vector2(x * t, y * t);
  }

  Vector2 div(T t) {
    return Vector2(x / t, y / t);
  }

  Vector2 normalize() {
    T norm = gcd(x.abs, y.abs);
    return norm > 0 ? this.div(norm) : this;
  }
}

void problem() {
  alias Vector = Vector2!long;
  auto N = scan!long;
  auto P = N.iota.map!(_ => Vector(scan!long, scan!long)).array;

  void solve() {
    foreach(combination; P.combinations(3)){
      combination.deb;
      auto base = combination[0];
      auto d1 = base.sub(combination[1]).normalize;
      auto d2 = base.sub(combination[2]).normalize;

      if (d1 == d2 || d1 == d2.mul(-1)) {
        writeln("Yes");
        return;
      }
    }

    writeln("No");
  }

  solve();
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }

struct CombinationRange(T) {
  private {
    int combinationSize;
    int elementSize;
    int pointer;
    int[] cursor;
    T[] elements;
    T[] current;
  }

  public:

  this(T[] t, int combinationSize) {
    this.combinationSize = combinationSize;
    this.elementSize = cast(int)t.length;
    pointer = combinationSize - 1;
    cursor = new int[combinationSize];
    current = new T[combinationSize];
    elements = t.dup;
    foreach(i; 0..combinationSize) {
      cursor[i] = i;
      current[i] = elements[i];
    }
  }

  @property T[] front() {
    return current;
  }

  void popFront() {
    if (pointer == -1) return;

    if (cursor[pointer] == elementSize + pointer - combinationSize) {
      pointer--;
      popFront();
      if (pointer < 0) return;

      pointer++;
      cursor[pointer] = cursor[pointer - 1];
      current[pointer] = elements[cursor[pointer]];
    }

    cursor[pointer]++;
    current[pointer] = elements[cursor[pointer]];
  }

  bool empty() {
    return pointer == -1;
  }
}
CombinationRange!T combinations(T)(T[] t, int size) { return CombinationRange!T(t, size); }

alias Point = Tuple!(long, "x", long, "y");

// -----------------------------------------------
