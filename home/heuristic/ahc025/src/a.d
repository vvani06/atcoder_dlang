import std;

void main() {
  int N = scan!int;
  int D = scan!int;
  int Q = scan!int;

  auto solve() {
    foreach(_; 0..Q) {
      int[] setL, setR;

      setL ~= iota(N / 2).randomSample(3).array;
      setR ~= iota(N / 2, N).randomSample(3).array;

      writefln("%s %s %(%s %) %(%s %)", setL.length, setR.length, setL, setR);
      stdout.flush();

      scan();
    }

    int[] ans = new int[](N);
    foreach(i; 0..N) {
      if (i < D) {
        ans[i] = i;
      } else {
        ans[i] = uniform(0, D);
      }
    }

    writefln("%(%s %)", ans);
    stdout.flush();
  }

  solve();
}

// ----------------------------------------------

string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
T[] divisors(T)(T n) { T[] ret; for (T i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }

// -----------------------------------------------
