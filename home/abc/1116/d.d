import std.stdio, std.conv, std.array, std.string;
import std.container, std.algorithm, std.range;
import std.numeric, std.math, std.typecons, std.functional;
import core.stdc.stdlib;

const MOD = 1000000000 + 7;

class FermetCalculator {
	long factrial[]; //階乗を保持
	long inverse[];  //逆元を保持
	
	this(int size) {
		factrial = new long[size + 1];
		inverse = new long[size + 1];
		factrial[0] = 1;
		inverse[0] = 1;
		
		for (int i = 1; i <= size; i++) {
			factrial[i] = (factrial[i - 1] * i) % MOD;  //階乗を求める
			inverse[i] = pow(factrial[i], MOD - 2) % MOD; // フェルマーの小定理で逆元を求める
		}
	}
	
	long combine(int n, int k) {
		return factrial[n] * inverse[k] % MOD * inverse[n - k] % MOD;
	}
	
	long pow(long x, int n) { //x^n 計算量O(logn)
		long ans = 1;
		while (n > 0) {
			if ((n & 1) == 1) {
				ans = ans * x % MOD;
			}
			x = x * x % MOD; //一周する度にx, x^2, x^4, x^8となる
			n >>= 1; //桁をずらす n = n >> 1
		}
		return ans;
	}
}

alias Vector = Tuple!(int, "x", int, "y");

void main() {
  int X, Y; readf("%d %d\n", &X, &Y);
  if (min(X, Y) * 2 < max(X, Y)) {
    writeln(0);
    exit(0);
  }

  int stepSize = 0;
  auto destination = Vector(X, Y);
  foreach(n; 1..666667) {
    auto base = Vector(2*n, n);
    auto diff = Vector(destination.x - base.x, destination.y - base.y);
    if (diff.x == -diff.y) {
      stepSize = n;
      break;
    }
  }

  if (stepSize == 0) {
    writeln(0);
    exit(0);
  }

  auto position = X - stepSize;
  writeln(new FermatCombination(stepSize).combine(stepSize, position));
}
