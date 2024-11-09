void main() { runSolver(); }

void problem() {
  auto S = scan!string;
  auto N = scan!int;
  auto T = scan!string(N);

  auto solve() {
    S = "~" ~ S ~ "_";
    auto sa = suffixArray(S);
    sa.deb;

    foreach(t; T) {
      auto tl = t.length.to!int;

      bool findL(int i) {
        return S[i..min($, i + tl)] < t;
      }
      bool findR(int i) {
        return S[i..min($, i + tl)] <= t;
      }

      auto l = binarySearch((int x) => sa[x], &findL, 0, S.length.to!int);
      auto r = binarySearch((int x) => sa[x], &findR, 0, S.length.to!int);
      (r - l).writeln;
    }
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std, core.bitop;
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
  else if (is(T == string)) fn().writeln;
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

K binarySearch(K)(bool delegate(K) cond, K l, K r) { return binarySearch((K k) => k, cond, l, r); }
T binarySearch(T, K)(K delegate(T) fn, bool delegate(K) cond, T l, T r) {
  auto ok = l;
  auto ng = r;
  const T TWO = 2;
 
  bool again() {
    static if (is(T == float) || is(T == double) || is(T == real)) {
      return !ng.approxEqual(ok, 1e-08, 1e-08);
    } else {
      return abs(ng - ok) > 1;
    }
  }
 
  while(again()) {
    const half = (ng + ok) / TWO;
    const halfValue = fn(half);
 
    if (cond(halfValue)) {
      ok = half;
    } else {
      ng = half;
    }
  }
 
  return ok;
}

// copied from: https://github.com/kotet/atcoder-library-d

int[] saNaive(const ref int[] s) @safe pure nothrow
{
    import std.range : iota, array;
    import std.algorithm : sort;

    int n = cast(int) s.length;
    auto sa = iota(n).array;
    bool less(int l, int r)
    {
        if (l == r)
            return false;
        while (l < n && r < n)
        {
            if (s[l] != s[r])
                return s[l] < s[r];
            l++;
            r++;
        }
        return l == n;
    }

    sort!(less)(sa);
    return sa;
}

int[] saDoubling(const ref int[] s) @safe pure nothrow
{
    import std.range : iota, array;
    import std.algorithm : sort, swap;

    int n = cast(int) s.length;
    auto sa = iota(n).array;
    auto rnk = s.dup;
    auto tmp = new int[](n);

    for (int k = 1; k < n; k *= 2)
    {
        bool less(int x, int y)
        {
            if (rnk[x] != rnk[y])
                return rnk[x] < rnk[y];
            int rx = x + k < n ? rnk[x + k] : -1;
            int ry = y + k < n ? rnk[y + k] : -1;
            return rx < ry;
        }

        sort!(less)(sa);
        tmp[sa[0]] = 0;
        foreach (i; 1 .. n)
            tmp[sa[i]] = tmp[sa[i - 1]] + (less(sa[i - 1], sa[i]) ? 1 : 0);
        swap(tmp, rnk);
    }
    return sa;
}

int[] saIs(int THRESHOLD_NAIVE = 10, int THRESHOLD_DOUBLING = 40)(int[] s, int upper)
{
    int n = cast(int) s.length;
    if (n == 0)
        return [];
    if (n == 1)
        return [0];
    if (n == 2)
    {
        if (s[0] < s[1])
        {
            return [0, 1];
        }
        else
        {
            return [1, 0];
        }
    }
    if (n < THRESHOLD_NAIVE)
        return saNaive(s);
    if (n < THRESHOLD_DOUBLING)
        return saDoubling(s);
    auto sa = new int[](n);
    auto ls = new bool[](n);
    foreach_reverse (i; 0 .. n - 2 + 1)
        ls[i] = (s[i] == s[i + 1]) ? ls[i + 1] : (s[i] < s[i + 1]);
    auto sum_l = new int[](upper + 1);
    auto sum_s = new int[](upper + 1);
    foreach (i; 0 .. n)
    {
        if (!ls[i])
        {
            sum_s[s[i]]++;
        }
        else
        {
            sum_l[s[i] + 1]++;
        }
    }
    foreach (i; 0 .. upper + 1)
    {
        sum_s[i] += sum_l[i];
        if (i < upper)
            sum_l[i + 1] += sum_s[i];
    }
    void induce(const ref int[] lms)
    {
        sa[] = -1;
        auto buf = new int[](upper + 1);
        buf[] = sum_s[];
        foreach (d; lms)
        {
            if (d == n)
                continue;
            sa[buf[s[d]]++] = d;
        }
        buf[] = sum_l[];
        sa[buf[s[n - 1]]++] = n - 1;
        foreach (i; 0 .. n)
        {
            int v = sa[i];
            if (1 <= v && !ls[v - 1])
                sa[buf[s[v - 1]]++] = v - 1;
        }
        buf[] = sum_l[];
        foreach_reverse (i; 0 .. n)
        {
            int v = sa[i];
            if (v >= 1 && ls[v - 1])
            {
                sa[--buf[s[v - 1] + 1]] = v - 1;
            }
        }
    }

    auto lms_map = new int[](n + 1);
    lms_map[] = -1;
    int m = 0;
    foreach (i; 1 .. n)
        if (!ls[i - 1] && ls[i])
            lms_map[i] = m++;
    int[] lms;
    lms.reserve(m);
    foreach (i; 1 .. n)
        if (!ls[i - 1] && ls[i])
            lms ~= i;

    induce(lms);

    if (m)
    {
        int[] sorted_lms;
        sorted_lms.reserve(m);
        foreach (int v; sa)
            if (lms_map[v] != -1)
                sorted_lms ~= v;
        auto rec_s = new int[](m);
        int rec_upper = 0;
        rec_s[lms_map[sorted_lms[0]]] = 0;
        foreach (i; 1 .. m)
        {
            int l = sorted_lms[i - 1];
            int r = sorted_lms[i];
            int end_l = (lms_map[l] + 1 < m) ? lms[lms_map[l] + 1] : n;
            int end_r = (lms_map[r] + 1 < m) ? lms[lms_map[r] + 1] : n;
            bool same = true;
            if (end_l - l != end_r - r)
            {
                same = false;
            }
            else
            {
                while (l < end_l)
                {
                    if (s[l] != s[r])
                        break;
                    l++;
                    r++;
                }
                if (l == n || s[l] != s[r])
                    same = false;
            }
            if (!same)
                rec_upper++;
            rec_s[lms_map[sorted_lms[i]]] = rec_upper;
        }
        auto rec_sa = saIs!(THRESHOLD_NAIVE, THRESHOLD_DOUBLING)(rec_s, rec_upper);
        foreach (i; 0 .. m)
            sorted_lms[i] = lms[rec_sa[i]];
        induce(sorted_lms);
    }
    return sa;
}

int[] suffixArray(int[] s, int upper) @safe pure nothrow
{
    assert(0 <= upper);
    foreach (int d; s)
        assert(0 <= d && d <= upper);
    auto sa = saIs(s, upper);
    return sa;
}

int[] suffixArray(T)(T[] s)
{
    import std.range : iota;
    import std.array : array;
    import std.algorithm : sort;

    int n = cast(int) s.length;
    int[] idx = iota(n).array;
    sort!((int l, int r) => s[l] < s[r])(idx);
    auto s2 = new int[](n);
    int now = 0;
    foreach (i; 0 .. n)
    {
        if (i && s[idx[i - 1]] != s[idx[i]])
            now++;
        s2[idx[i]] = now;
    }
    return saIs(s2, now);
}

int[] suffixArray(string s) @safe pure nothrow
{
    int n = cast(int) s.length;
    auto s2 = new int[](n);
    foreach (i; 0 .. n)
        s2[i] = s[i];
    return saIs(s2, 255);
}

int[] lcpArray(T)(T[] s, int[] sa)
{
    int n = cast(int) s.length;
    assert(n >= 1);
    auto rnk = new int[](n);
    foreach (i; 0 .. n)
        rnk[sa[i]] = i;
    auto lcp = new int[](n - 1);
    int h = 0;
    foreach (i; 0 .. n)
    {
        if (h > 0)
            h--;
        if (rnk[i] == 0)
            continue;
        int j = sa[rnk[i] - 1];
        for (; j + h < n && i + h < n; h++)
            if (s[j + h] != s[i + h])
                break;
        lcp[rnk[i] - 1] = h;
    }
    return lcp;
}

int[] lcpArray(string s, int[] sa) @safe pure nothrow
{
    int n = cast(int) s.length;
    auto s2 = new int[](n);
    foreach (i; 0 .. n)
        s2[i] = s[i];
    return lcpArray(s2, sa);
}

int[] zAlgorithm(T)(T[] s)
{
    import std.algorithm : min;

    int n = cast(int) s.length;
    if (n == 0)
        return [];
    auto z = new int[](n);
    int j;
    foreach (i; 1 .. n)
    {
        z[i] = (j + z[j] < i) ? 0 : min(j + z[j] - i, z[i - j]);
        while (i + z[i] < n && s[z[i]] == s[i + z[i]])
            z[i]++;
        if (j + z[j] < i + z[i])
            j = i;
    }
    z[0] = n;
    return z;
}

int[] zAlgorithm(string s) @safe pure nothrow
{
    int n = cast(int) s.length;
    auto s2 = new int[](n);
    foreach (i; 0 .. n)
    {
        s2[i] = s[i];
    }
    return zAlgorithm(s2);
}
