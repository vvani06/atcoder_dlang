void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto RND = Xorshift(0);

  int N = scan!int;
  int M = scan!int;
  int TN = scan!int;
  int LA = scan!int;
  int LB = scan!int;
  int[][] UV = scan!int(2 * M).chunks(2).array;
  int[] T = scan!int(TN);
  int[][] XY = scan!int(2 * N).chunks(2).array;

  int[][] graph = new int[][](N, 0);
  foreach(uv; UV) {
    graph[uv[0]] ~= uv[1];
    graph[uv[1]] ~= uv[0];
  }

  int[][] nexts = new int[][](N, N);
  foreach(to; 0..N) {
    int[] froms = new int[](N);
    froms[] = -1;
    froms[to] = to;
    for(auto queue = DList!int(to); !queue.empty;) {
      auto cur = queue.front;
      queue.removeFront;

      foreach(next; graph[cur]) {
        if (froms[next] != -1) continue;

        queue.insertBack(next);
        froms[next] = cur;
      }
      foreach(from; 0..N) {
        nexts[from][to] = froms[from];
      }
    }
  }

  nexts[0].deb;

  {
    string ans;
    auto signals = (N.iota.array.randomShuffle.array ~ N.iota.array.randomShuffle.array)[0..LA];
    ans ~= format("%(%s %) \n", signals);

    auto indiciesForSignal = new int[](N);
    indiciesForSignal[] = -1;
    foreach(i, s; signals.enumerate(0)) {
      if (indiciesForSignal[s] != -1) continue;

      indiciesForSignal[s] = i;
    }

    int cur = 0;
    int[] visitable = (-1).repeat(LB).array;

    foreach(t; T) {
      while(cur != t) {
        cur = nexts[cur][t];
        if (!visitable.canFind(cur)) {
          auto sigLeft = indiciesForSignal[cur];
          auto sigSize = min(LA - sigLeft, LB);
          ans ~= format("s %d %d %d \n", sigSize, sigLeft, 0);
          visitable[0..sigSize] = signals[sigLeft..sigLeft + sigSize].dup;
        }

        ans ~= format("m %d \n", cur);
      }
    }

    ans.writeln;
  }


  "FIN".deb;
}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
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
