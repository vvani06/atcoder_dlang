void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  struct Target {
    string s;
    int p;
    int[] ids;

    int[] nodes() {
      int[dchar] dict;
      foreach(i, c; chars()) dict[c] = i.to!int;
      return s.map!(c => dict[c]).array;
    }

    int kind() {
      return s.array.sort.uniq.walkLength.to!int;
    }

    int perf() {
      return p / kind();
    }

    string chars() {
      return s.array.sort.uniq.to!string;
    }
  }

  int N = scan!int;
  int M = scan!int;
  int L = scan!int;
  auto SP = N.iota.map!(_ => Target(scan, scan!int, [_])).array;

  Target combine(int[] indicies) {
    string s = SP[indicies[0]].s;
    int p = SP[indicies[0]].p;
    foreach(i; indicies[1..$]) {
      int intersect;
      foreach(j, c; SP[i].s) {
        if (c == s[$ - 1 - j]) intersect++; else break;
      }

      s ~= SP[i].s[intersect..$];
      p += SP[i].p / 2;
    }
    return Target(s, p, indicies.map!(i => SP[i].ids).joiner.array);
  }

  // SP.sort!"a.perf > b.perf";
  // foreach(i; 0..N - 1) {
  //   foreach(j; i + 1..N) {
  //     if (SP[i].s[$ - 1] == SP[j].s[0]) SP ~= combine([i, j]);
  //   }
  // }
  
  auto P_MAX = SP.map!"a.p".maxElement;
  auto P_RATIO = P_MAX / 100;

  enum ELM = "abcdef";
  enum OTHERS_WEIGHT = 1;

  int rest = M;
  int ofs = 0;
  bool[] used = new bool[](N);
  int[] headers;
  
  foreach(target; SP.sort!"a.perf > b.perf") {
    auto size = target.kind();
    if (size > rest) continue;
    if (target.ids.any!(i => used[i])) continue;

    target.deb;
    target.nodes.deb;
    auto ll = target.s.length * 10;

    auto matrix = new real[][](size, size);
    foreach(ref m; matrix) m[] = 0;
    int pre = target.nodes[0];
    foreach(next; target.nodes[1..$]) {
      matrix[pre][next] += ll;
      ll--;
      pre = next;
    }

    auto matrixInt = new int[][](size, size);
    real scale = 100 - OTHERS_WEIGHT * (M - size);
    foreach(i; 0..size) {
      auto rowSum = matrix[i].sum;
      if (rowSum == 0) {
        rowSum = matrix[i][target.nodes[0]] = 1; 
      }
      foreach(j; 0..size) {
        matrix[i][j] *= scale;
        matrix[i][j] /= rowSum;
      }
      matrix[i].deb;
      matrixInt[i] = matrix[i].map!"a.to!int".array;
      while(matrixInt[i].sum < 100 - OTHERS_WEIGHT * (M - size)) {
        matrixInt[i][uniform(0, size, RND)]++;
      }
      matrixInt[i].swapAt(0, target.nodes[0]);
    }

    string[] ans;
    foreach(c, m; zip(target.chars(), matrixInt)) {
      int[] arr = OTHERS_WEIGHT.repeat(M).array;
      arr[ofs..ofs + size] = m;
      ans ~= "%s %(%d %)".format(c, arr);
    }
    ans.swapAt(0, target.nodes[0]);

    foreach(s; ans) {
      writeln(s);
    }

    headers ~= ofs;
    ofs += size;
    rest -= size;
    foreach(u; target.ids) used[u] = true;
  }

  foreach(_; 0..rest) {
    int[] arr = 3.repeat(M).array;
    foreach(i; headers) arr[i] = (50.0 / headers.length).to!int;
    while(arr.sum < 100) arr[uniform(0, M, RND)]++;
    writefln("%s %(%d %)", ELM[_ % $], arr);
  }
}

// ----------------------------------------------

import std;
import core.bitop;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(lazy T t){ debug { write("# "); writeln(t); }}
void debf(T ...)(lazy T t){ debug { write("# "); writefln(t); }}
// void deb(T ...)(T t){ debug {  }}
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
  problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
