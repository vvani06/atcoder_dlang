
struct IndexedValue(I, T) {
  I index;
  T value;
  alias value this;

  this(I index, T value) {
    this.index = index;
    this.value = value;
  }
}

auto indexed(I, R)(R range, I origin = 0L) if(isInputRange!R) {
  IndexedValue!(I, ElementType!R)[] ret;
  auto i = origin;

  foreach(a; range) {
    ret ~= IndexedValue!(I, ElementType!R)(i, a);
  }
  return  ret;
}

