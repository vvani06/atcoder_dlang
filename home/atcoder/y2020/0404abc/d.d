void main() {
  problem();
}

class LunlunNumber {
  long number;

  this(long n) {
    deb([n]);
    number = n;

    if (!isValid) {
      throw new Exception("invalid number");
    }
  }

  bool isValid() {
    auto digits = number.digits;
    foreach(i; 1..digits.length) {
      const spread = digits[i] - digits[i-1];
      if (spread < -1 || spread > 1) return false;
    }

    return true;
  }

  LunlunNumber next() {
    if (number < 10) return new LunlunNumber(number + 1);

    auto digits = number.digits;
    if (digits.all!(d => d == 9)) return new LunlunNumber(number + 1);

    auto limit = digits.length - 1;
    foreach(i; 0..limit) {
      if (digits[i] < 9 && digits[i+1] >= digits[i]) {
        digits[i]++;
        break;
      }
      digits[i] = 0;

      if (i+1 == limit) {
        digits[i+1]++;
      }
    }

    foreach_reverse(i; 0..limit) {
      if (digits[i+1] - digits[i] > 1) {
        digits[i] = digits[i+1] == 0 ? 0 : cast(byte)(digits[i+1] - 1);
      }
    }

    return new LunlunNumber(digits.digitsTo!long);
  }

  override string toString() {
    return number.to!string;
  }

}

void problem() {
  const K = scan!long;

  long solve() {
    auto lunlun = new LunlunNumber(1);
    foreach(i; 1..K) {
      lunlun = lunlun.next();
    }

    return lunlun.number;
  }

  solve().writeln;
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.functional;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(int n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");

byte[] digits(T)(T t) {
  byte[] digits = new byte[16];

  int i;
  while(true) {
    digits[i++] = t % 10;

    if ((t /= 10) == 0) break;
  }
  digits.length = i;

  return digits;
}

T digitsTo(T)(byte[] digits) {
  T t;
  T dec = 1;
  foreach(digit; digits) {
    t += dec * digit;
    dec *= 10;
  }
  return t;
}

// -----------------------------------------------
