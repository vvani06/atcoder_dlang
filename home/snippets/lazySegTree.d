static struct TypicalLazySegTree(S) {
  static struct VS {
    S value;
    int size;
  }
  static VS withSize(S d) { return VS(d, 1); }
  static VS[] withSize(S[] data) { return data.map!withSize.array; }

  alias MinAdd = LazySegTree!(S, minFunc, sMax, S, addFunc, addFunc, sZero);
  alias MinUpdate = LazySegTree!(S, minFunc, sMax, S, updateFunc!sMax, updateFunc!sMax, sMax);
  alias MaxAdd = LazySegTree!(S, maxFunc, sMin, S, addFunc, addFunc, sZero);
  alias MaxUpdate = LazySegTree!(S, maxFunc, sMin, S, updateFunc!sMin, updateFunc!sMin, sMin);
  alias SumAdd = LazySegTree!(VS, addVSFunc, vsZero, S, addVSMapping, addFunc, sZero);
  alias SumUpdate = LazySegTree!(VS, addVSFunc, vsZero, S, updateVSMapping!sMax, updateFunc!sMax, sMax);

  private:
    enum minFunc = "min(a, b)";
    enum maxFunc = "max(a, b)";
    enum addFunc = "a + b";
    enum updateFunc(alias id) = (S f, S x) => f == unaryFun!id() ? x : f;
    enum sMax = () => S.max / 3;
    enum sMin = () => S.min / 3;
    enum sZero = () => 0.to!S;

    enum addVSFunc = (VS a, VS b) => VS(a.value + b.value, a.size + b.size);
    enum addVSMapping = (S f, VS x) => VS(x.value + f*x.size, x.size);
    enum updateVSMapping(alias id) = (S f, VS x) => VS(f == unaryFun!id() ? x.value : f*x.size, x.size);
    enum vsZero = () => VS(0, 0);
}

// copied from: https://github.com/kotet/atcoder-library-d/blob/master/source/acl/lazy_segtree.d
struct LazySegTree(S, alias op, alias e, F, alias mapping, alias composition, alias id)
{
    import std.functional : unaryFun, binaryFun;
    import std.traits : isCallable, Parameters;

    static if (is(typeof(e) : string))
    {
        auto unit()
        {
            return mixin(e);
        }
    }
    else
    {
        alias unit = e;
    }
    static if (is(typeof(id) : string))
    {
        auto identity()
        {
            return mixin(id);
        }
    }
    else
    {
        alias identity = id;
    }
  public:
      this(int n)
      {
          auto v = new S[](n);
          v[] = unit();
          this(v);
      }

      this(const S[] v)
      {
          _n = cast(int) v.length;
          log = celiPow2(_n);
          size = 1 << log;
          assert(1 <= size);
          d = new S[](2 * size);
          d[] = unit();
          lz = new F[](size);
          lz[] = identity();
          foreach (i; 0 .. _n)
              d[size + i] = v[i];
          foreach_reverse (i; 1 .. size)
              update(i);
      }

      void set(int p, S x)
      {
          assert(0 <= p && p < _n);
          p += size;
          foreach_reverse (i; 1 .. log + 1)
              push(p >> i);
          d[p] = x;
          foreach (i; 1 .. log + 1)
              update(p >> i);
      }

      S get(int p)
      {
          assert(0 <= p && p < _n);
          p += size;
          foreach_reverse (i; 1 .. log + 1)
              push(p >> i);
          return d[p];
      }

      S prod(int l, int r)
      {
          assert(0 <= l && l <= r && r <= _n);
          if (l == r)
              return unit();
          l += size;
          r += size;
          foreach_reverse (i; 1 .. log + 1)
          {
              if (((l >> i) << i) != l)
                  push(l >> i);
              if (((r >> i) << i) != r)
                  push(r >> i);
          }

          S sml = unit(), smr = unit();
          while (l < r)
          {
              if (l & 1)
                  sml = binaryFun!(op)(sml, d[l++]);
              if (r & 1)
                  smr = binaryFun!(op)(d[--r], smr);
              l >>= 1;
              r >>= 1;
          }

          return binaryFun!(op)(sml, smr);
      }

      S allProd()
      {
          return d[1];
      }

      void apply(int p, F f)
      {
          assert(0 <= p && p < _n);
          p += size;
          foreach_reverse (i; 1 .. log + 1)
              push(p >> i);
          d[p] = binaryFun!(mapping)(f, d[p]);
          foreach (i; 1 .. log + 1)
              update(p >> i);
      }

      void apply(int l, int r, F f)
      {
          assert(0 <= l && l <= r && r <= _n);
          if (l == r)
              return;
          l += size;
          r += size;
          foreach_reverse (i; 1 .. log + 1)
          {
              if (((l >> i) << i) != l)
                  push(l >> i);
              if (((r >> i) << i) != r)
                  push((r - 1) >> i);
          }
          {
              int l2 = l, r2 = r;
              while (l < r)
              {
                  if (l & 1)
                      all_apply(l++, f);
                  if (r & 1)
                      all_apply(--r, f);
                  l >>= 1;
                  r >>= 1;
              }
              l = l2;
              r = r2;
          }
          foreach (i; 1 .. log + 1)
          {
              if (((l >> i) << i) != l)
                  update(l >> i);
              if (((r >> i) << i) != r)
                  update((r - 1) >> i);
          }
      }

      int maxRight(alias g)(int l)
      {
          return maxRight(l, unaryFun!(g));
      }

      int maxRight(G)(int l, G g) if (isCallable!G && Parameters!(G).length == 1)
      {
          assert(0 <= l && l <= _n);
          assert(g(unit()));
          if (l == _n)
              return _n;
          l += size;
          foreach_reverse (i; 1 .. log + 1)
              push(l >> i);
          S sm = unit();
          do
          {
              while (l % 2 == 0)
                  l >>= 1;
              if (!g(binaryFun!(op)(sm, d[l])))
              {
                  while (l < size)
                  {
                      push(l);
                      l = 2 * l;
                      if (g(binaryFun!(op)(sm, d[l])))
                      {
                          sm = binaryFun!(op)(sm, d[l]);
                          l++;
                      }
                  }
                  return l - size;
              }
              sm = binaryFun!(op)(sm, d[l]);
              l++;
          }
          while ((l & -l) != l);
          return _n;
      }

      int minLeft(alias g)(int r)
      {
          return minLeft(r, unaryFun!(g));
      }

      int minLeft(G)(int r, G g) if (isCallable!G && Parameters!(G).length == 1)
      {
          assert(0 <= r && r <= _n);
          assert(g(unit()));
          if (r == 0)
              return 0;
          r += size;
          foreach_reverse (i; 1 .. log + 1)
              push((r - 1) >> i);
          S sm = unit();
          do
          {
              r--;
              while (r > 1 && (r % 2))
                  r >>= 1;
              if (!g(binaryFun!(op)(d[r], sm)))
              {
                  while (r < size)
                  {
                      push(r);
                      r = (2 * r + 1);
                      if (g(binaryFun!(op)(d[r], sm)))
                      {
                          sm = binaryFun!(op)(d[r], sm);
                          r--;
                      }
                  }
                  return r + 1 - size;
              }
              sm = binaryFun!(op)(d[r], sm);
          }
          while ((r & -r) != r);
          return 0;
      }

  private:
      int _n = 0, size = 1, log = 0;
      S[] d = [unit(), unit()];
      F[] lz = [identity()];

      int celiPow2(int n) @safe pure nothrow @nogc
      {
          int x = 0;
          while ((1u << x) < cast(uint)(n))
              x++;
          return x;
      }

      void update(int k)
      {
          d[k] = binaryFun!(op)(d[2 * k], d[2 * k + 1]);
      }

      void all_apply(int k, F f)
      {
          d[k] = binaryFun!(mapping)(f, d[k]);
          if (k < size)
              lz[k] = binaryFun!(composition)(f, lz[k]);
      }

      void push(int k)
      {
          all_apply(2 * k, lz[k]);
          all_apply(2 * k + 1, lz[k]);
          lz[k] = identity();
      }
}
