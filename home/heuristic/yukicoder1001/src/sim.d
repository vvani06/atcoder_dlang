import std;

void main() {
  enum int T = 52;
  enum int N = 10;
  long money = 2_000_000;

  auto pipe = pipeProcess("./a", Redirect.stdout | Redirect.stdin);

  pipe.stdin.writefln("%d %d %d", T, N, money);
  pipe.stdin.flush();

  int[] potentials = iota(5, 15).map!"a * 100".array;
  int[] popularities = new int[](10);
  long[] stocks = new long[](10);

  long score;
  foreach(_; 1..T) {
    auto inp = pipe.stdout.readln.chomp.split;
    inp.writeln;
    auto strategy = inp[0].to!int;
    if (strategy == 1) {
      auto orders = inp[1..$].map!"a.to!long".array;
      money -= orders.sum * 500;
      foreach(i; 0..N) {
        stocks[i] += orders[i];
      }
    } else {
      auto level = inp[1].to!int;
      long cost = 500_000L * 2L^^(level - 1);
      money -= cost;
      foreach(i; 0..N) {
        popularities[i] = min(60, popularities[i] + level);
      }
    }

    if (money < 0) {
      pipe.stdin.writeln(-1);
      stderr.writeln("no money");
      return;
    } else {
      auto sold = new long[](N);
      foreach(i; 0..N) {
        if (stocks[i] == 0) continue;

        real value = stocks[i].to!real.sqrt;
        value *= uniform(0.75f, 1.25f);
        value *= potentials[i].to!real / 1000;
        value *= pow(1.05f, popularities[i]);
        sold[i] = min(stocks[i], value.to!long);

        if (sold[i] * 10 >= stocks[i] * 3) popularities[i]++;
        if (sold[i] * 10 <  stocks[i] * 1) popularities[i]--;
        popularities[i] = min(60, max(-60, popularities[i]));
        stocks[i] -= sold[i];
      }

      money += sold.sum * 1000;
      pipe.stdin.writeln(money);
      pipe.stdin.writefln("%(%d %)", sold);
      pipe.stdin.writefln("%(%d %)", popularities);
      pipe.stdin.writefln("%(%d %)", stocks);
      pipe.stdin.flush();
      
      writeln(money);
      writefln("%(%d %)", sold);
      writefln("%(%d %)", popularities);
      writefln("%(%d %)", stocks);
      score += sold.sum;
    }
  }

  writeln(score);
}
