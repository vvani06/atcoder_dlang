void main() { runSolver(); }

// ----------------------------------------------

alias Vector = Vector2!long;
enum int LIMIT = 10 ^^ 4 + 1;
enum long BOUNDARY = 10L ^^ 6 + 1;

struct Line {
  long sx, sy, ex, ey;

  string toString() {
    return [sx, sy, ex, ey].toAnswerString;
  }

  static Line atY(long y) { return Line(-BOUNDARY, y, BOUNDARY, y + 1); }
  static Line atX(long x) { return Line(x, -BOUNDARY, x + 1, BOUNDARY); }
}

void problem() {
  auto N = scan!int;
  auto OPERATION_LIMIT = scan!int;
  auto A = scan!int(10);
  auto P = N.iota.map!(_ => Vector(scan!long, scan!long)).array.sort!"a.y < b.y";
  auto rnd = Xorshift(unpredictableSeed);
  int ratio = 3;

  auto solve() {
    auto rest = OPERATION_LIMIT;
    Line[] ans;
    Vector[][] ps;
    {
      int cut;
      int i;
      int count;
      bool canCut() {
        return count >= ratio;
      }
      Vector[] pss;
      foreach(y; -LIMIT..LIMIT) {
        if (rest == 0) break;
        while(i < N && P[i].y <= y) {
          count++;
          pss ~= P[i];
          if (++i == N) break;
        }
        if (canCut) {
          cut++;
          ps ~= pss;
          ans ~= Line.atY(y);
          count = 0;
          pss = [];
          rest--;
        }
        if (N == i && !pss.empty) {
          ps ~= pss;
          break;
        }
      }
    }

    foreach(ref p; ps) p.sort!"a.x < b.x";

    long maxScore = -1;
    Line[] maxLines;
    int[] badCount = new int[](10);

    Line[] lines;
    auto restX = rest;
    auto desires = new int[](N);
    desires[1..11] = A.dup;

    auto psn = ps.length.to!int;
    auto psl = ps.map!"a.length.to!int".array;
    auto psi = new int[](psn);
    auto psiTb = new int[](psn);
    int xTb = -LIMIT;
    auto count = new int[](psn);
    long bestScore;
    int[int] addsTb;
    int preX = -LIMIT;

    long calcScore() {
      long ret;
      int[11] t;
      foreach(c; count) if (c <= 10) t[c]++;
      foreach(i; 1..11) {
        if (desires[i] <= 0) continue;
        ret += t[i] * (desires[i] + 3) / 4;
      }
      return ret;
    }

    for(int x = -LIMIT; x < LIMIT; x++) {
      if (restX == 0) break;

      foreach(i; 0..psn) {
        while(psi[i] < psl[i] && ps[i][psi[i]].x <= x) {
          count[i]++;
          psi[i]++;
        }
      }
      
      if (bestScore.chmax(calcScore)) {
        psiTb = psi.dup;
        int[int] adds;
        foreach(c; count) adds[c]++;
        addsTb = adds;
        xTb = x;
      }
      if (bestScore > 0 && (x >= LIMIT - 1 || x - preX >= 5000)) {
        lines ~= Line.atX(xTb);
        restX--;
        count[] = 0;
        foreach(k, v; addsTb) desires[k] = max(0, desires[k] - v);
        bestScore = 0;
        psi = psiTb;
        preX = x = xTb;
      }
    }

    long eval = 10.iota.map!(i => A[i] - desires[i + 1]).sum * 10L^^6;
    if (maxScore.chmax(eval)) {
      maxLines = lines;
      badCount = desires[1..11].dup;
    }

    ans ~= maxLines;
    const tested = maxScore / A.sum;
    debug {
      stderr.writefln("score: %s (rest %s/%s %s)", tested, badCount.sum, A.sum, badCount);
      ans.length.writeln;
    } else {
      stderr.writefln("%s", tested);
      ans.length.writeln;
      return ans;
    }
  }

  foreach(i; iota(100, 701, 10)) {
    ratio = i;
    outputForAtCoder(&solve);
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
}
