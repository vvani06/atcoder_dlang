void main() {
  problem();
}

struct Matrix2 {
  long[][] v;

  this(long[][] value) {
    v = value;
  }

  long x() {
    return v[0][2];
  }

  long y() {
    return v[1][2];
  }

  Point mul(Point p) {
    auto m = [p.x, p.y, 1];
    auto mm = [0L, 0, 0];
    foreach(i; 0..3) {
      foreach(j; 0..3) mm[i] += v[i][j] * m[j];
    }

    return Point(mm[0], mm[1]);
  }

  Matrix2 mul(Matrix2 other) {
    auto vd = [[0L, 0, 0], [0L, 0, 0], [0L, 0, 0]];
    foreach(i; 0..3) {
      foreach(j; 0..3) {
        // deb("----- ", i, ", ", j);
        foreach(k; 0..3) {
          vd[i][j] += v[i][k] * other.v[k][j];
        }
      }
    }
    // deb("a: ", v);
    // deb("b: ", other.v);
    // deb("ab: ", vd);
    return Matrix2(vd);
  }

  static Matrix2 from(long x, long y) {
    return Matrix2([
      [1 , 0, x],
      [0L, 1, y],
      [0L, 0, 1]
    ]);
  }

  static Matrix2 moveX(long x) {
    return Matrix2([
      [1L, 0, x],
      [0L, 1, 0],
      [0L, 0, 1]
    ]);
  }

  static Matrix2 mirrorX() {
    return Matrix2([
      [-1L,  0, 0],
      [ 0L,  1, 0],
      [ 0L,  0, 1]
    ]);
  }

  static Matrix2 moveY(long y) {
    return Matrix2([
      [1L, 0, 0],
      [0L, 1, y],
      [0L, 0, 1]
    ]);
  }

  static Matrix2 mirrorY() {
    return Matrix2([
      [1L,   0, 0],
      [0L , -1, 0],
      [0L ,  0, 1]
    ]);
  }

  static Matrix2 rotateLeft() {
    return Matrix2([
      [0L, -1, 0],
      [1L,  0, 0],
      [0L,  0, 1]
    ]);
  }

  static Matrix2 rotateRight() {
    return Matrix2([
      [ 0L, 1, 0],
      [-1L, 0, 0],
      [ 0L, 0, 1]
    ]);
  }
}

void problem() {
  auto N = scan!long;
  auto P = N.iota.map!(_ => Point(scan!long, scan!long)).array;
  auto M = scan!long;
  auto OP = M.iota.map!(_ => scan!long).map!(a => a <= 2 ? Operation(a, -1) : Operation(a, scan!long)).array;
  auto Q = scan!long;
  auto QU = Q.iota.map!(_ => Query(scan!long, scan!long - 1)).array;

  void solve() {
    P.deb;
    OP.deb;
    QU.deb;

    Matrix2[] mat = new Matrix2[M + 1];
    mat[0].v = [[1, 0, 0], [0, 1, 0], [0, 0, 1]];
    foreach(i, op; OP) {
      if (op.op == 1) mat[i + 1] = Matrix2.rotateRight().mul(mat[i]);
      if (op.op == 2) mat[i + 1] = Matrix2.rotateLeft().mul(mat[i]);
      if (op.op == 3) {
        mat[i + 1] = Matrix2.moveX(op.base).mul(Matrix2.mirrorX()).mul(Matrix2.moveX(op.base * -1)).mul(mat[i]);
      } 
      if (op.op == 4) {
        mat[i + 1] = Matrix2.moveY(op.base).mul(Matrix2.mirrorY()).mul(Matrix2.moveY(op.base * -1)).mul(mat[i]);
      }

      // mat[i + 1].deb;
    }

    foreach(q; QU) {
      auto p = mat[q.term].mul(P[q.point]);
      writefln("%s %s", p.x, p.y);
    }
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
alias Query = Tuple!(long, "term", long, "point");
alias Operation = Tuple!(long, "op", long, "base");
ulong MOD = 10^^9 + 7;
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }

// -----------------------------------------------
