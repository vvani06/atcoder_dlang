
class TrieTree(T) {
  class Node {
    T value;
    int count;
    Node[T] children;
    Node parent;
    bool last;

    this(T c, Node p) {
      value = c;
      parent = p;
    }

    Node next(T c) {
      return children.get(c, null);
    }

    void insert(T c) {
      children[c] = new Node(c, this);
    }

    void remove(T c) {
      children.remove(c);
    }

    override string toString() {
      return "TrieNode: %s (%s) [%(%s %)]".format(value, count, children.keys);
    }
  }

  Node root;
  this() {
    root = new Node(0, null);
  }

  Node[] search(S)(S s) {
    Node[] ret;

    Node cur = root;
    foreach(c; s) {
      cur = cur.next(c);

      if (cur is null) break; else ret ~= cur;
    }
    return ret;
  }

  Node remove(S)(S s) {
    Node cur = root;
    foreach(i, c; s) {
      if (i == s.length - 1 && cur.next(c)) {
        auto target = cur.next(c);
        cur.remove(c);
        while(cur !is null) {
          cur.count -= target.count;
          cur = cur.parent;
        }
        return target;
      }

      if ((cur = cur.next(c)) is null) break;
    }
    return null;
  }

  Node insert(S)(S s) {
    Node cur = root;
    foreach(c; s) {
      if (cur.next(c) is null) {
        cur.insert(c);
      }

      cur = cur.next(c);
      cur.count++;
    }

    cur.last = true;
    return cur;
  }
}
