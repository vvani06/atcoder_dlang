import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;

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

  uint income = 0;
  uint[] candidates = new uint[N];
  auto heap = heapify(candidates, 0);
  foreach(day; 1..DAYS+1) {
    if (day in incomes) incomes[day].each!(d => heap.insert(d));
    if (heap.empty()) continue;

    income += heap.front;
    heap.removeFront();
  }
  writeln(income);
}
