void main() { runSolver(); }

// ---------------------------------------------

void problem() {
  int N = scan!int;
  int id(int y, int x) { return y + x * N; }
  
  auto RND = Xorshift(0);
  auto StartTime = MonoTime.currTime();
  bool elapsed(int ms) { 
    return (ms <= (MonoTime.currTime() - StartTime).total!"msecs");
  }

  int NN = N * N;
  string[] H = scan!string(N - 1);
  string[] V = scan!string(N);
  long[] DR = scan!long(NN);
  long[] D = (NN).iota.map!(i => DR[id(i / N, i % N)]).array;

  enum LEFT = 0;
  enum UP = 1;
  enum RIGHT = 2;
  enum DOWN = 3;
  enum DIRS = "LURD";
  enum DX = [-1, 0, 1, 0];
  enum DY = [0, -1, 0, 1];

  struct Path {
    int to, dir;
  }

  struct Moves {
    string moves;
    int size = int.max;
  }

  Path[][] graph = new Path[][](NN, 0);
  foreach(y; 0..N - 1) foreach(x; 0..N) {
    if (H[y][x] == '0') {
      graph[id(y, x)] ~= Path(id(y + 1, x), DOWN);
      graph[id(y + 1, x)] ~= Path(id(y, x), UP);
    }
  }
  foreach(y; 0..N) foreach(x; 0..N - 1) {
    if (V[y][x] == '0') {
      graph[id(y, x)] ~= Path(id(y, x + 1), RIGHT);
      graph[id(y, x + 1)] ~= Path(id(y, x), LEFT);
    }
  }

  Moves[] bfsAll(int from) {
    auto ret = new Moves[](NN);
    ret[from].size = 0;

    for(auto queue = DList!int(from); !queue.empty;) {
      auto cur = queue.front; queue.removeFront;

      foreach(next; graph[cur]) {
        if (ret[next.to].size != int.max) continue;

        ret[next.to].moves = ret[cur].moves ~ DIRS[next.dir];
        ret[next.to].size = ret[cur].size + 1;
        queue.insert(next.to);
      }
    }
    return ret;
  }
  
  auto allPath = NN.iota.map!(f => bfsAll(f)).array;

  Tuple!(string, int) bfsSet(int from, RedBlackTree!int toSet) {
    int best = int.max;
    int bestTo;
    foreach(to; toSet) {
      if (best.chmin(allPath[from][to].size)) {
        bestTo = to;
      }
    }
    return tuple(allPath[from][bestTo].moves, bestTo);
  }

  Tuple!(string, int) bfs(int from, int to) {
    return tuple(allPath[from][to].moves, to);
  }

  struct Route {
    int[] route;
    string[] moves;
    RedBlackTree!int[] visited;
    long score = long.max;

    alias Ans = Tuple!(string, long);

    this(int[] route) {
      visited = NN.iota.map!(_ => new int[](0).redBlackTree).array;
      this.route = route.dup;
      calc();
    }

    void calc() {
      moves.length = 0;
      foreach(ref v; visited) v.clear;

      int cur;
      foreach(r; route) {
        auto ret = bfs(cur, r);
        moves ~= ret[0];
        cur = ret[1];
      }
      score = calcScore(moves.joiner.to!string);
    }

    Ans toAns() {
      return Ans(moves.joiner.to!string, score);
    }

    long calcScore(string moves) {
      auto rn = moves.length.to!int;
      int pre;
      foreach(i, d; moves) {
        visited[pre].insert(i.to!int);
        
        if (d == DIRS[LEFT]) pre-=N;
        if (d == DIRS[RIGHT]) pre+=N;
        if (d == DIRS[UP]) pre--;
        if (d == DIRS[DOWN]) pre++;
      }
      visited[0].insert(rn);

      long ret;
      foreach(i; 0..NN) {
        int pret = visited[i].back - rn;
        foreach(t; visited[i].array ~ rn) {
          auto span = t - pret;
          if (pret < 0) {
            ret += D[i] * - pret * t;
            ret += D[i] * t * (t - 1) / 2;
          } else {
            ret += D[i] * span * (span - 1) / 2;
          }
          pret = t;
        }
      }

      return ret / rn;
    }

    void addTo(int index, int to) {
      int preLength = moves[0..index].map!"a.length.to!int".sum;
      string moves1 = bfs(route[index - 1], to)[0];
      string moves2 = bfs(to, route[index])[0];
      int lengthDelta = [moves1, moves2].map!"a.length.to!int".sum - moves[index].length.to!int;
      int removeLength = preLength + moves[index].length.to!int;

      auto newVisited = NN.iota.map!(_ => new int[](0).redBlackTree).array;
      foreach(i; 0..NN) {
        foreach(t; visited[i]) {
          if (t < preLength) {
            newVisited[i].insert(t);
          } else if (t < removeLength) {
            // ignore entry
          } else {
            newVisited[i].insert(t + lengthDelta);
          }
        }
      }

      int pre = route[index - 1];
      foreach(i, d; moves1 ~ moves2) {
        newVisited[pre].insert(preLength + i.to!int);
        
        if (d == DIRS[LEFT]) pre-=N;
        if (d == DIRS[RIGHT]) pre+=N;
        if (d == DIRS[UP]) pre--;
        if (d == DIRS[DOWN]) pre++;
      }

      // newVisited.deb;
      int rn = moves.map!"a.length.to!int".sum + lengthDelta;
      long newScore;
      foreach(i; 0..NN) {
        if (newVisited[i].empty) return;

        int pret = newVisited[i].back - rn;
        foreach(t; newVisited[i].array ~ rn) {
          auto span = t - pret;
          if (pret < 0) {
            newScore += D[i] * - pret * t;
            newScore += D[i] * t * (t - 1) / 2;
          } else {
            newScore += D[i] * span * (span - 1) / 2;
          }
          pret = t;
        }
      }
      
      newScore /= rn;
      if (score > newScore) {
        // [1, newScore, score].deb;

        route.insertInPlace(index, to);
        moves.replace(index, index + 1, [moves1, moves2]);
        visited = newVisited;
        score = newScore;
      }
    }

    void remove(int index) {
      int preLength = moves[0..index].map!"a.length.to!int".sum;
      string moves1 = bfs(route[index - 1], route[index + 1])[0];
      int lengthDelta = moves1.length.to!int - moves[index].length.to!int - moves[index + 1].length.to!int;
      int removeLength = preLength + moves[index].length.to!int + moves[index + 1].length.to!int;

      auto newVisited = NN.iota.map!(_ => new int[](0).redBlackTree).array;
      foreach(i; 0..NN) {
        foreach(t; visited[i]) {
          if (t < preLength) {
            newVisited[i].insert(t);
          } else if (t < removeLength) {
            // ignore entry
          } else {
            newVisited[i].insert(t + lengthDelta);
          }
        }
      }

      int pre = route[index - 1];
      foreach(i, d; moves1) {
        newVisited[pre].insert(preLength + i.to!int);
        
        if (d == DIRS[LEFT]) pre-=N;
        if (d == DIRS[RIGHT]) pre+=N;
        if (d == DIRS[UP]) pre--;
        if (d == DIRS[DOWN]) pre++;
      }

      // newVisited.deb;
      int rn = moves.map!"a.length.to!int".sum + lengthDelta;
      long newScore;
      foreach(i; 0..NN) {
        if (newVisited[i].empty) return;

        int pret = newVisited[i].back - rn;
        foreach(t; newVisited[i].array ~ rn) {
          auto span = t - pret;
          if (pret < 0) {
            newScore += D[i] * - pret * t;
            newScore += D[i] * t * (t - 1) / 2;
          } else {
            newScore += D[i] * span * (span - 1) / 2;
          }
          pret = t;
        }
      }
      
      newScore /= rn;
      if (score > newScore) {
        // [-1, newScore, score].deb;

        route.replaceInPlace(index, index + 1, new int[](0));
        moves.replaceInPlace(index, index + 2, [moves1]);
        visited = newVisited;
        score = newScore;
      }
    }
      
    int opCmp(Route other) {
      return cmp([toAns()[1]], [other.toAns()[1]]);
    }
  }

  auto solve() {
    int[] initialRoute; {
      int pre;
      foreach(y; 0..N) foreach(x; y % 2 == 0 ? N.iota.array : N.iota.retro.array) {
        initialRoute ~= pre = id(y, x);
      }

      auto ranked = D.enumerate(0).array.sort!"a[1] > b[1]";
      auto toVisits = ranked[0..$ / 4].map!"a[0]".redBlackTree;
      while(!toVisits.empty) {
        auto route = bfsSet(pre, toVisits);
        initialRoute ~= pre = route[1];
        toVisits.removeKey(pre);
      }
      initialRoute ~= 0;
    }
    int[] initialRoute2; {
      int pre;
      foreach(x; 0..N) foreach(y; x % 2 == 0 ? N.iota.array : N.iota.retro.array) {
        initialRoute2 ~= pre = id(y, x);
      }

      auto ranked = D.enumerate(0).array.sort!"a[1] > b[1]";
      auto toVisits = ranked[0..$ / 4].map!"a[0]".redBlackTree;
      while(!toVisits.empty) {
        auto route = bfsSet(pre, toVisits);
        initialRoute2 ~= pre = route[1];
        toVisits.removeKey(pre);
      }
      initialRoute2 ~= 0;
    }
    int[] initialRoute3; {
      int pre;
      {
        int preY, preX, dir;
        auto visited = new bool[](NN);
        visited[0] = true;
        int visitedCount = 1;
        while(visitedCount < NN) {
          while(true) {
            auto y = preY + DY[dir];
            auto x = preX + DX[dir];
            if (min(x, y) >= 0 && max(x, y) < N && !visited[id(y, x)]) break;

            dir = (dir + 1) % 4;
          }

          preY = preY + DY[dir];
          preX = preX + DX[dir];
          initialRoute3 ~= id(preY, preX);
          visited[id(preY, preX)] = true;
          visitedCount++;
        }
      }

      auto ranked = D.enumerate(0).array.sort!"a[1] > b[1]";
      auto toVisits = ranked[0..$ / 4].map!"a[0]".redBlackTree;
      while(!toVisits.empty) {
        auto route = bfsSet(pre, toVisits);
        initialRoute3 ~= pre = route[1];
        toVisits.removeKey(pre);
      }
      initialRoute3 ~= 0;
    }
    int[] initialRoute4; {
      int pre;
      {
        int preY, preX, dir;
        auto visited = new bool[](NN);
        visited[0] = true;
        int visitedCount = 1;
        while(visitedCount < NN) {
          while(true) {
            auto y = preY + DY[dir];
            auto x = preX + DX[dir];
            if (min(x, y) >= 0 && max(x, y) < N && !visited[id(y, x)]) break;

            dir = (dir + 3) % 4;
          }

          preY = preY + DY[dir];
          preX = preX + DX[dir];
          initialRoute4 ~= id(preY, preX);
          visited[id(preY, preX)] = true;
          visitedCount++;
        }
      }

      auto ranked = D.enumerate(0).array.sort!"a[1] > b[1]";
      auto toVisits = ranked[0..$ / 4].map!"a[0]".redBlackTree;
      while(!toVisits.empty) {
        auto route = bfsSet(pre, toVisits);
        initialRoute4 ~= pre = route[1];
        toVisits.removeKey(pre);
      }
      initialRoute4 ~= 0;
    }

    auto ranked = D.enumerate(0).array.sort!"a[1] > b[1]";
    auto toVisits = ranked[0..$ / 5].map!"a[0]".array;
    // auto bestRoute = min(Route(initialRoute), Route(initialRoute2), Route(initialRoute3));
    auto bestRoute = min(Route(initialRoute3), Route(initialRoute4));

    int tried;
    while(!elapsed(8000)) {
      auto index = uniform(1, bestRoute.route.length.to!int, RND);
      auto toVisit = toVisits.choice(RND);
      bestRoute.addTo(index, toVisit);

      auto removeIndex = uniform(1, bestRoute.route.length.to!int - 1, RND);
      bestRoute.remove(removeIndex);
      tried++;
    }
    
    [[tried]].deb;
    auto ans = bestRoute.toAns();
    ans[1].deb;
    ans[0].writeln;
  }

  solve();
}

// ----------------------------------------------

import std;
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
  problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
