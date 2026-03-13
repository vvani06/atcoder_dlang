
struct FunctionalGraph {
  int nodeSize;
  int[] graph;

  this(int ns, int[] g) {
    nodeSize = ns;
    graph = g.dup;
  }

  this(int ns, int delegate(int) fn) {
    nodeSize = ns;
    graph = iota(ns).map!(i => fn(i)).array;
  }

  int[] walk(long step) {
    int[] ret = iota(nodeSize).array;
    auto nexts = graph.dup;
    foreach(i; 0..63) {
      if (step & 1) ret = ret.map!(x => nexts[x]).array;

      nexts = iota(nodeSize).map!(j => nexts[nexts[j]]).array;
      step >>= 1;
    }
    return ret;
  }
}
