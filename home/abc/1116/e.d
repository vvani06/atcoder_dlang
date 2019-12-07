import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;

class Nodes(T) {

  class Node {
    public int id;
    public Node[] friends;

    public T content;
    alias content this;

    this(int id) {
      this.id = id;
    }
  }

  public int origin;
  public Node[int] nodes;

  this(int size, int origin = 1) {
    this.origin = origin;
    size.iota.each!((i) {
      auto id = origin + i;
      this.nodes[id] = new Node(id);
    });
  }

  void setPath(int a, int b) {
    this.nodes[a].friends ~= this.nodes[b];
    this.nodes[b].friends ~= this.nodes[a];
  }

  Node root() {
    return this.nodes[origin];
  }

  void apply(int id, void delegate(Node) d) {
    d(this.nodes[id]);
  }

  void applyAllFromRoot(void delegate(Node) d) {
    auto cursors = [this.root()];
    bool[int] checked;
    while(!cursors.empty) {
      foreach(node; cursors) {
        d(node);
        checked[node.id] = true;
      }
      cursors = cursors.map!(node => node.friends)
        .joiner.filter!(node => node !is null && node.id !in checked).array;
    }
  }
}

struct Counter {
  int count;
}

void main() {
  int N, Q; readf("%d %d\n", &N, &Q);

  auto nodes = new Nodes!(Counter)(N);
  foreach(i; 1..N) {
    int from, to; readf("%d %d\n", &from, &to);
    nodes.setPath(from, to);
  }
  
  foreach(i; 0..Q) {
    int nodeId, increments; readf("%d %d\n", &nodeId, &increments);
    nodes.apply(nodeId, (node){ node.count += increments; });
  }

  int[] totals = new int[N+1];
  nodes.applyAllFromRoot((node) {
    totals[node.id] += node.count;
    node.friends.each!(n => totals[node.id] += totals[n.id]);
  });

  totals.popFront();
  totals.to!(string[]).join(" ").writeln;
}
