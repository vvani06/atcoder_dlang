
struct Set(T) {
  private bool[T] v;
  this(T t) { v[t] = true; }
  this(InputRange!T r) { foreach(t; r) v[t] = true; }
  
  size_t length() { return v.length; }
  bool has(T t) { return !!(t in v); }
  auto opIndex() { return v.keys; }

  bool add(T t) { if (t in v) return false; else return v[t] = true; }
  void add(InputRange!T r) { foreach(t; r) add(t); }
  void add(Set!T s) { foreach(t; s[]) add(t); }
  bool remove(T t) { if (!(t in v)) return false; else { v.remove(t); return true; }}
  void remove(InputRange!T r) { foreach(t; r) remove(t); }
  void remove(Set!T s) { foreach(t; s[]) remove(t); }
}
