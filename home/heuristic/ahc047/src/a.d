void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { return (ms <= (MonoTime.currTime() - StartTime).total!"msecs"); }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  int N = scan!int;
  int M = scan!int;
  int L = scan!int;
  auto SP = N.iota.map!(_ => tuple(scan, scan!int)).array;
  
  enum ELM = "abcdef";
  auto P_MAX = SP.map!"a[1]".maxElement;
  auto P_RATIO = P_MAX / 5;

  foreach(offset; 0..2) {
    int[6][6] matrix;
    int[] start = new int[](6);
    foreach(sp; SP.sort!"a[1] > b[1]"[offset..offset + 1]) {
      char pre = sp[0][0];
      start[pre - 'a'] += max(1, sp[1] / P_RATIO) ^^ 4;
      foreach(i; 0..6) matrix[i][pre - 'a'] += max(1, sp[1] / P_RATIO) ^^ 4;
      foreach(next; sp[0][1..$]) {
        matrix[pre - 'a'][next - 'a'] += max(1, sp[1] / P_RATIO) ^^ 5;
        pre = next;
      }
    }
    // foreach(m; matrix) m.deb;

    int[][] candidates = new int[][](6, 0);
    foreach(i; 0..6) {
      foreach(j; 0..6) {
        candidates[i] ~= j.repeat(matrix[i][j]).array;
      }
    }

    auto maxi = start.maxIndex;
    string[] ans;
    foreach(i; 0..6) {
      auto s = [ELM[i % $]].to!string;
      auto arr = 1.repeat(M).array;
      foreach(_; arr.sum..100) {
        arr[offset * 6 + candidates[i].choice(RND)]++;
      }
      arr.swapAt(offset * 6, offset * 6 + maxi);
      ans ~= format("%s %(%d %)", s, arr);
    }
    ans.swapAt(0, maxi);
    foreach(s; ans) writeln(s);
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
