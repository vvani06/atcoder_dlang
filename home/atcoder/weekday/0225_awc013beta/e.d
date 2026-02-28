void main() { runSolver(); }

void problem() {
  auto N = scan!int;
  auto M = scan!int;
  auto C = iota(N).map!(_ => scan!int(scan!int)).array;

  auto solve() {
    auto graph = MFGraph!int(N + M + 2);
    foreach(m; 0..M) graph.addEdge(N + 1 + m, N + M + 1, 1);
    foreach(i, cs; C.enumerate(0)) {
      graph.addEdge(0, i + 1, 1);
      foreach(c; cs) {
        graph.addEdge(i + 1, N + c, 1);
      }
    }
    return graph.flow(0, N + M + 1);
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std;
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
T[] compress(T)(T[] arr, T origin = T.init) { T[T] indecies; arr.dup.sort.uniq.enumerate(origin).each!((i, t) => indecies[t] = i); return arr.map!(t => indecies[t]).array; }
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
struct ModInt(uint MD) if (MD < int.max) {ulong v;this(string v) {this(v.to!long);}this(int v) {this(long(v));}this(long v) {this.v = (v%MD+MD)%MD;}void opAssign(long t) {v = (t%MD+MD)%MD;}static auto normS(ulong x) {return (x<MD)?x:x-MD;}static auto make(ulong x) {ModInt m; m.v = x; return m;}auto opBinary(string op:"+")(ModInt r) const {return make(normS(v+r.v));}auto opBinary(string op:"-")(ModInt r) const {return make(normS(v+MD-r.v));}auto opBinary(string op:"*")(ModInt r) const {return make((ulong(v)*r.v%MD).to!ulong);}auto opBinary(string op:"^^", T)(T r) const {long x=v;long y=1;while(r){if(r%2==1)y=(y*x)%MD;x=x^^2%MD;r/=2;} return make(y);}auto opBinary(string op:"/")(ModInt r) const {return this*memoize!inv(r);}static ModInt inv(ModInt x) {return x^^(MD-2);}string toString() const {return v.to!string;}auto opOpAssign(string op)(ModInt r) {return mixin ("this=this"~op~"r");}}
alias MInt1 = ModInt!(10^^9 + 7);
alias MInt9 = ModInt!(998_244_353);
string asAnswer(T ...)(T t) {
  string ret;
  foreach(i, a; t) {
    if (i > 0) ret ~= "\n";
    alias A = typeof(a);
    static if (isIterable!A && !is(A == string)) {
      string[] rets;
      foreach(b; a) rets ~= asAnswer(b);
      static if (isInputRange!A) ret ~= rets.joiner(" ").to!string; else ret ~= rets.joiner("\n").to!string; 
    } else {
      static if (is(A == float) || is(A == double) || is(A == real)) ret ~= "%.16f".format(a);
      else static if (is(A == bool)) ret ~= YESNO[a]; else ret ~= "%s".format(a);
    }
  }
  return ret;
}
void deb(T ...)(T t){ debug t.writeln; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
  else asAnswer(fn()).writeln;
}
void runSolver() {
  static import std.datetime.stopwatch;
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(!stdin.eof) { "<<< Process time: %s >>>".writefln(std.datetime.stopwatch.benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------

auto asTuples(int L, T)(T matrix) {
  static if (__traits(compiles, L)) {
    return matrix.map!(row => mixin(format("tuple(%-(row[%s],%)])", L.iota)));
  } else {
    return matrix.map!(row => tuple());
  }
}

unittest
{
    MFGraph!int g1;
    auto g2 = MFGraph!int(0);
}

unittest
{
    MFGraph!int g;
    g = MFGraph!int(10);
}

unittest
{
    auto g = MFGraph!int(4);
    assert(0 == g.addEdge(0, 1, 1));
    assert(1 == g.addEdge(0, 2, 1));
    assert(2 == g.addEdge(1, 3, 1));
    assert(3 == g.addEdge(2, 3, 1));
    assert(4 == g.addEdge(1, 2, 1));
    assert(2 == g.flow(0, 3));

    assert(MFGraph!(int).Edge(0, 1, 1, 1) == g.getEdge(0));
    assert(MFGraph!(int).Edge(0, 2, 1, 1) == g.getEdge(1));
    assert(MFGraph!(int).Edge(1, 3, 1, 1) == g.getEdge(2));
    assert(MFGraph!(int).Edge(2, 3, 1, 1) == g.getEdge(3));
    assert(MFGraph!(int).Edge(1, 2, 1, 0) == g.getEdge(4));
}

unittest
{
    auto g = MFGraph!int(2);
    assert(0 == g.addEdge(0, 1, 1));
    assert(1 == g.addEdge(0, 1, 2));
    assert(2 == g.addEdge(0, 1, 3));
    assert(3 == g.addEdge(0, 1, 4));
    assert(4 == g.addEdge(0, 1, 5));
    assert(5 == g.addEdge(0, 0, 6));
    assert(6 == g.addEdge(1, 1, 7));
    assert(15 == g.flow(0, 1));

    assert(MFGraph!(int).Edge(0, 1, 1, 1) == g.getEdge(0));
    assert(MFGraph!(int).Edge(0, 1, 2, 2) == g.getEdge(1));
    assert(MFGraph!(int).Edge(0, 1, 3, 3) == g.getEdge(2));
    assert(MFGraph!(int).Edge(0, 1, 4, 4) == g.getEdge(3));
    assert(MFGraph!(int).Edge(0, 1, 5, 5) == g.getEdge(4));

    assert([true, false] == g.minCut(0));
}

unittest
{
    auto g = MFGraph!int(3);
    assert(0 == g.addEdge(0, 1, 2));
    assert(1 == g.addEdge(1, 2, 1));
    assert(1 == g.flow(0, 2));

    assert(MFGraph!(int).Edge(0, 1, 2, 1) == g.getEdge(0));
    assert(MFGraph!(int).Edge(1, 2, 1, 1) == g.getEdge(1));

    assert([true, true, false] == g.minCut(0));
}

unittest
{
    auto g = MFGraph!(int)(3);
    assert(0 == g.addEdge(0, 1, 1));
    assert(1 == g.addEdge(0, 2, 1));
    assert(2 == g.addEdge(1, 2, 1));
    assert(2 == g.flow(0, 2));

    assert(MFGraph!(int).Edge(0, 1, 1, 1) == g.getEdge(0));
    assert(MFGraph!(int).Edge(0, 2, 1, 1) == g.getEdge(1));
    assert(MFGraph!(int).Edge(1, 2, 1, 1) == g.getEdge(2));

    g.changeEdge(0, 100, 10);
    assert(MFGraph!(int).Edge(0, 1, 100, 10) == g.getEdge(0));
    assert(0 == g.flow(0, 2));
    assert(90 == g.flow(0, 1));

    assert(MFGraph!(int).Edge(0, 1, 100, 100) == g.getEdge(0));
    assert(MFGraph!(int).Edge(0, 2, 1, 1) == g.getEdge(1));
    assert(MFGraph!(int).Edge(1, 2, 1, 1) == g.getEdge(2));

    assert(2 == g.flow(2, 0));

    assert(MFGraph!(int).Edge(0, 1, 100, 99) == g.getEdge(0));
    assert(MFGraph!(int).Edge(0, 2, 1, 0) == g.getEdge(1));
    assert(MFGraph!(int).Edge(1, 2, 1, 0) == g.getEdge(2));
}

unittest
{
    immutable INF = int.max;

    auto g = MFGraph!(int)(3);
    assert(0 == g.addEdge(0, 1, INF));
    assert(1 == g.addEdge(1, 0, INF));
    assert(2 == g.addEdge(0, 2, INF));

    assert(INF == g.flow(0, 2));

    assert(MFGraph!(int).Edge(0, 1, INF, 0) == g.getEdge(0));
    assert(MFGraph!(int).Edge(1, 0, INF, 0) == g.getEdge(1));
    assert(MFGraph!(int).Edge(0, 2, INF, INF) == g.getEdge(2));
}

unittest
{
    immutable INF = uint.max;

    auto g = MFGraph!(uint)(3);
    assert(0 == g.addEdge(0, 1, INF));
    assert(1 == g.addEdge(1, 0, INF));
    assert(2 == g.addEdge(0, 2, INF));

    assert(INF == g.flow(0, 2));

    assert(MFGraph!(uint).Edge(0, 1, INF, 0) == g.getEdge(0));
    assert(MFGraph!(uint).Edge(1, 0, INF, 0) == g.getEdge(1));
    assert(MFGraph!(uint).Edge(0, 2, INF, INF) == g.getEdge(2));
}

unittest
{
    auto g = MFGraph!int(3);
    assert(0 == g.addEdge(0, 0, 100));
    assert(MFGraph!(int).Edge(0, 0, 100, 0) == g.getEdge(0));
}

unittest
{
    import std.exception;

    auto g = MFGraph!int(2);
    assertThrown!Error(g.flow(0, 0));
    assertThrown!Error(g.flow(0, 0, 0));
}

unittest
{
    import std.random : uniform, randomSample;
    import std.algorithm : swap;
    import std.meta : AliasSeq;
    import std.typecons : Tuple;

    Tuple!(T, T) randpair(T)(T lower, T upper)
    {
        assert(upper - lower >= 1);
        T a, b;
        do
        {
            a = uniform(lower, upper + 1);
            b = uniform(lower, upper + 1);
        }
        while (a == b);
        if (a > b)
            swap(a, b);
        return Tuple!(T, T)(a, b);
    }

    foreach (phase; 0 .. 10_000)
    {
        int n = uniform(2, 20 + 1);
        int m = uniform(1, 100 + 1);
        int s, t;
        auto rand = randpair(0, n - 1);
        s = rand[0], t = rand[1];
        if (uniform!"[]"(0, 1))
            swap(s, t);

        auto g = MFGraph!int(n);
        foreach (i; 0 .. m)
        {
            int u = uniform(0, n - 1 + 1);
            int v = uniform(0, n - 1 + 1);
            int c = uniform(0, n - 1 + 1);
            g.addEdge(u, v, c);
        }
        int flow = g.flow(s, t);
        int dual = 0;
        auto cut = g.minCut(s);
        auto v_flow = new int[](n);
        foreach (e; g.edges())
        {
            v_flow[e.from] -= e.flow;
            v_flow[e.to] += e.flow;
            if (cut[e.from] && !cut[e.to])
                dual += e.cap;
        }
        assert(flow == dual);
        assert(-flow == v_flow[s]);
        assert(flow == v_flow[t]);
        foreach (i; 0 .. n)
        {
            if (i == s || i == t)
                continue;
            assert(0 == v_flow[i]);
        }
    }
}

// --- maxflow ---

struct MFGraph(Cap)
{
    import std.typecons : Tuple;

public:
    this(int n)
    {
        _n = n;
        g = new _edge[][](n);
    }

    int addEdge(int from, int to, Cap cap)
    {
        assert(0 <= from && from < _n);
        assert(0 <= to && to < _n);
        assert(0 <= cap);
        int m = cast(int) pos.length;
        pos ~= Tuple!(int, int)(from, cast(int)(g[from].length));
        int from_id = cast(int) g[from].length;
        int to_id = cast(int) g[to].length;
        if (from == to)
            to_id++;
        g[from] ~= _edge(to, to_id, cap);
        g[to] ~= _edge(from, from_id, 0);
        return m;
    }

    struct Edge
    {
        int from, to;
        Cap cap, flow;
    }

    Edge getEdge(int i)
    {
        int m = cast(int)(pos.length);
        assert(0 <= i && i < m);
        auto _e = g[pos[i][0]][pos[i][1]];
        auto _re = g[_e.to][_e.rev];
        return Edge(pos[i][0], _e.to, _e.cap + _re.cap, _re.cap);
    }

    Edge[] edges()
    {
        int m = cast(int)(pos.length);
        Edge[] result;
        foreach (i; 0 .. m)
            result ~= getEdge(i);
        return result;
    }

    void changeEdge(int i, Cap new_cap, Cap new_flow)
    {
        int m = cast(int)(pos.length);
        assert(0 <= i && i < m);
        assert(0 <= new_flow && new_flow <= new_cap);
        auto _e = &g[pos[i][0]][pos[i][1]];
        auto _re = &g[_e.to][_e.rev];
        _e.cap = new_cap - new_flow;
        _re.cap = new_flow;
    }

    Cap flow(int s, int t)
    {
        return flow(s, t, Cap.max);
    }

    Cap flow(int s, int t, Cap flow_limit)
    {
        import std.container : DList;
        import std.algorithm : min;

        assert(0 <= s && s < _n);
        assert(0 <= t && t < _n);
        assert(s != t);

        auto level = new int[](_n), iter = new int[](_n);
        DList!int que;

        void bfs()
        {
            level[] = -1;
            level[s] = 0;
            que.clear();
            que.insertBack(s);
            while (!que.empty)
            {
                int v = que.front;
                que.removeFront();
                foreach (e; g[v])
                {
                    if (e.cap == 0 || level[e.to] >= 0)
                        continue;
                    level[e.to] = level[v] + 1;
                    if (e.to == t)
                        return;
                    que.insertBack(e.to);
                }
            }
        }

        Cap dfs(int v, Cap up)
        {
            if (v == s)
                return up;
            Cap res = 0;
            int level_v = level[v];
            for (; iter[v] < cast(int)(g[v].length); iter[v]++)
            {
                auto i = iter[v];
                auto e = g[v][i];
                if (level_v <= level[e.to] || g[e.to][e.rev].cap == 0)
                    continue;
                Cap d = dfs(e.to, min(up - res, g[e.to][e.rev].cap));
                if (d <= 0)
                    continue;
                g[v][i].cap += d;
                g[e.to][e.rev].cap -= d;
                res += d;
                if (res == up)
                    break;
            }
            return res;
        }

        Cap flow = 0;
        while (flow < flow_limit)
        {
            bfs();
            if (level[t] == -1)
                break;
            iter[] = 0;
            while (flow < flow_limit)
            {
                Cap f = dfs(t, flow_limit - flow);
                if (!f)
                    break;
                flow += f;
            }
        }
        return flow;
    }

    bool[] minCut(int s)
    {
        import std.container : DList;

        auto visited = new bool[](_n);
        DList!int que;
        que.insertBack(s);
        while (!que.empty)
        {
            int p = que.front;
            que.removeFront();
            visited[p] = true;
            foreach (e; g[p])
            {
                if (e.cap && !visited[e.to])
                {
                    visited[e.to] = true;
                    que.insertBack(e.to);
                }
            }
        }
        return visited;
    }

private:
    struct _edge
    {
        int to, rev;
        Cap cap;
    }

    int _n;
    Tuple!(int, int)[] pos;
    _edge[][] g;
}