import std.stdio, std.conv, std.array;
import std.algorithm;
import std.typecons;

void main() {
  int N, DAYS;
  readf("%d %d\n", &N, &DAYS);

  uint[][uint] incomes;

  foreach(i; 0..N) {
    int income, delay;
    readf("%d %d\n", &delay, &income);
    
    
    if (delay in incomes)
      incomes[delay] ~= income;
    else
      incomes[delay] = [income];
  }

  auto delays = incomes.keys;
  sort(delays);
  foreach(delay; delays) {
    incomes[delay].sort!("a > b");
  }
  // writeln(incomes);

  uint income = 0;
  foreach(day; 1..DAYS+1) {
    int max_income, max_delay;
    foreach(delay; delays) {
      if (delay > day) break;
      if (max_income > incomes[delay][0]) continue;

      max_income = incomes[delay][0];
      max_delay = delay;
    }
    if (max_income == 0) continue;

    income += max_income;
    incomes[max_delay].popFront();
    if (incomes[max_delay].length == 0) {
      delays = delays.remove!(a => a == max_delay);
    }
  }
  writeln(income);
}
