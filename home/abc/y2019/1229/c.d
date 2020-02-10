import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons;
T[][] combinations(T)(T[] s, in int m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }

void main() {
  auto X = readln.chomp.to!int;

  bool isPrime(int n)
  {
    if (n == 2)
    {
        return true;
    }
    else if (n % 2 == 0 || n < 2)
    {
        return false;
    }
    else
    {
        for (int i = 3; i <= sqrt(float(n)); i += 2)
        {
            if (n % i == 0)
            {
                return false;
            }
        }
    }
    return true;
  }
  
  for(int i = X; true; i++) {
    if (i > 2 && i % 2 == 0) continue;

    if (isPrime(i)) {
      writeln(i);
      break;
    }
  }
}
