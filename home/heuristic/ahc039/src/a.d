void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }
  auto seed = 983_741_243;
  auto RND = Xorshift(seed);
  enum long INF = long.max / 3;

  enum int AREA_SIZE = 10 ^^ 5;
  enum int SPAN = 1;
  
  int BLOCK_SIZE = 20000;
  int BLOCK_NUM = (AREA_SIZE + BLOCK_SIZE - 1) / BLOCK_SIZE;

  struct Coord {
    int r, c;

    Coord asBlock() {
      return Coord(r / BLOCK_SIZE, c / BLOCK_SIZE);
    }

    T of(T)(T[][] t) {
      return t[r][c];
    }
  }

  struct Block {
    int r, c, value;
    bool joint = false;

    Coord lu() { return Coord(r * BLOCK_SIZE + SPAN, c * BLOCK_SIZE); }
    Coord ru() { return Coord(r * BLOCK_SIZE + SPAN, (c + 1) * BLOCK_SIZE); }
    Coord ld() { return Coord((r + 1) * BLOCK_SIZE - SPAN, c * BLOCK_SIZE); }
    Coord rd() { return Coord((r + 1) * BLOCK_SIZE - SPAN, (c + 1) * BLOCK_SIZE); }
    
    Coord jru() { return Coord(r * BLOCK_SIZE + BLOCK_SIZE / 2, (c + 1) * BLOCK_SIZE); }
    Coord jrd() { return Coord(r * BLOCK_SIZE + BLOCK_SIZE / 2 + 1, (c + 1) * BLOCK_SIZE); }
    Coord jlu() { return Coord(r * BLOCK_SIZE + BLOCK_SIZE / 2, c * BLOCK_SIZE); }
    Coord jld() { return Coord(r * BLOCK_SIZE + BLOCK_SIZE / 2 + 1, c * BLOCK_SIZE); }
  }

  int N = scan!int;
  Coord[] Mackerels = scan!int(2 * N).chunks(2).map!(ab => Coord(ab[0], ab[1])).array;
  Coord[] Sardines = scan!int(2 * N).chunks(2).map!(ab => Coord(ab[0], ab[1])).array;

  int[][] blockValue = new int[][](BLOCK_NUM, BLOCK_NUM);
  foreach(c; Mackerels.map!"a.asBlock()") {
    blockValue[c.r][c.c]++;
  }
  foreach(c; Sardines.map!"a.asBlock()") {
    blockValue[c.r][c.c]--;
  }

  blockValue.each!deb;
  auto blocks = cartesianProduct(BLOCK_NUM.iota, BLOCK_NUM.iota).map!(a => Block(a[0], a[1], blockValue[a[0]][a[1]])).filter!"a.value > 0".array;
  blocks.sort!"a.value > b.value";
  auto blockLength = blocks.length.to!int;

  Coord[] bestAns;
  long bestScore;

  foreach_reverse(useBlocks; 1..blockLength) {
    auto candidates = blocks[0..useBlocks];
    candidates.map!"a.value".sum.deb;

    auto rMin = candidates.map!"a.r".minElement;
    auto rMax = candidates.map!"a.r".maxElement;
    auto cMin = candidates.map!"a.c".minElement;
    auto cMax = candidates.map!"a.c".maxElement;

    Block[][int] blocksPerRow;
    foreach(block; candidates.sort!"a.c < b.c") blocksPerRow[block.r] ~= block;

    Block[Block] rights, downs; {
      int preRow = rMin;
      foreach(row; blocksPerRow.keys.sort) {
        if (blocksPerRow[row][0].c != cMin) blocksPerRow[row] = Block(row, cMin, 0, true) ~ blocksPerRow[row];
        foreach(i, block; blocksPerRow[row][0..$ - 1]) {
          rights[block] = blocksPerRow[row][i + 1];
        }

        if (row != rMin) {
          downs[blocksPerRow[preRow][0]] = blocksPerRow[row][0];
        }
        preRow = row;
      }
    }

    Coord[] ans;
    Coord cur;
    long score;
    void dfs(Block block, int dir, Block pre) {
      score += blockValue[block.r][block.c];

      if (dir == 0) {
        ans ~= block.lu;
        ans ~= block.ru;
        cur = block.ru;
      }
      if (dir == 1) {
        if (cur != block.lu) {
          ans ~= block.jlu;
          ans ~= block.lu;
        }
        ans ~= block.ru;
        cur = block.ru;
      }
      if (dir == 2) {
        if (cur != block.ru) {
          ans ~= block.ru;
          cur = block.ru;
        }
      }

      if (block in rights) {
        auto next = rights[block];
        
        if (next.c != block.c + 1) {
          ans ~= block.jru;
          cur = block.jru;
        }
        dfs(next, 1, block);
        if (next.c != block.c + 1) {
          ans ~= block.jrd;
          cur = block.jrd;
        }
      }

      if (cur != block.rd) {
        ans ~= block.rd;
        cur = block.rd;
      }

      if (block in downs) {
        auto next = downs[block];
        
        dfs(next, 2, block);
      }

      ans ~= block.ld;
      cur = block.ld;

      if (dir == 1) {
        if (block.c != pre.c + 1) {
          ans ~= block.jld;
          cur = block.jld;
        }
      }

      if (dir == 2) {
        ans ~= block.lu;
        cur = block.lu;
      }
    }

    dfs(blocksPerRow[rMin][0], 0, blocksPerRow[rMin][0]);

    long len;
    foreach(i; 0..ans.length - 1) {
      len += abs(ans[i].r - ans[i + 1].r) + abs(ans[i].c - ans[i + 1].c);
    }

    if (len <= 4 * 10^^5) {
      if (bestScore.chmax(score)) {
        bestAns = ans;
      }
    }
  }

  bestScore.deb;
  bestAns.length.writeln;
  foreach(a; bestAns) writefln("%s %s", a.r, a.c);
}

// ----------------------------------------------

import std;
import core.memory : GC;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("# "); writeln(t); }}
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

struct UnionFind {
  int[] roots;
  int[] sizes;
  long[] weights;
 
  this(int size) {
    roots = size.iota.array;
    sizes = 1.repeat(size).array;
    weights = 0L.repeat(size).array;
  }
 
  int root(int x) {
    if (roots[x] == x) return x;

    const root = root(roots[x]);
    weights[x] += weights[roots[x]];
    return roots[x] = root;
  }

  int size(int x) {
    return sizes[root(x)];
  }
 
  bool unite(int x, int y, long w = 0) {
    int rootX = root(x);
    int rootY = root(y);
    if (rootX == rootY) return weights[x] - weights[y] == w;
 
    if (sizes[rootX] < sizes[rootY]) {
      swap(x, y);
      swap(rootX, rootY);
      w *= -1;
    }

    sizes[rootX] += sizes[rootY];
    weights[rootY] = weights[x] - weights[y] - w;
    roots[rootY] = rootX;
    return true;
  }
 
  bool same(int x, int y, int w = 0) {
    int rootX = root(x);
    int rootY = root(y);
 
    return rootX == rootY && weights[rootX] - weights[rootY] == w;
  }
}
