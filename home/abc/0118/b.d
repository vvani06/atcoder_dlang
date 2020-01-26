import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }


class Robot {
  int x;
  int r;
  int left, right;
  bool isActive;
  Robot[] othersInRange;
  int others;

  this(int[] xr) {
    x = xr[0];
    r = xr[1];
    left = x - r;
    right = x + r;
    isActive = true;
  }

  void disable() {
    isActive = false;
    foreach(r; othersInRange) {
      r.others--;
    }
  }

  void addOthers(Robot robot) {
    others++;
    othersInRange ~= robot;
  }

  bool isIndependentTo(Robot robot) {
    if (x == robot.x) return true;

    return left >= robot.right || right <= robot.left;
  }

  override string toString() {
    return format("Robot(x: %s, r: %s, others: %s)", x, r, others);
  }
}

class RangeManager {
  int[][] ranges;

  void add(Robot robot) {
    
  }
}

void main() {
  auto N = readln.chomp.to!(int);
  auto R = N.iota.map!(x => new Robot(readln.split.to!(int[]))).array();
  auto X_RBT = redBlackTree(R.map!(r => r.x).array);

  Robot[int] RX;
  foreach(r; R) RX[r.x] = r;

  void solve() {
    R.sort!((a, b) => a.left < b.left);
    for (int i = 0; i < N; i++) {
      auto base = R[i];
      foreach (r; R) {
        if (r.x == base.x) continue;
        if (r.right <= base.right) continue;
        if (r.left >= base.right) break;

        base.addOthers(r);
      }
      // for(int s = 1; s < (i > N-i ? i : N-i); s++) {
      //   if (i - s > 0) {
      //     auto other = R[i-s];
      //     if (!other.isActive) continue;
      //     if (!base.isIndependentTo(other)) other.disable();
      //   }
      //   if (i + s < N) {
      //     auto other = R[i+s];
      //     if (!other.isActive) continue;
      //     if (!base.isIndependentTo(other)) other.disable();
      //   }
      // }
    }

    auto others_sorted = R.dup.sort!((a, b) => a.others > b.others);
    while(others_sorted[0].others > 0) {
      others_sorted[0].disable();
      others_sorted.sort!((a, b) => a.others > b.others);
      others_sorted.writeln();
      others_sorted.popFront();
    }
    
    writeln(others_sorted.array.length);
  }

  solve();
}
