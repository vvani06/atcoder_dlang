import std.stdio, std.conv, std.array, std.string;
import std.algorithm;
import std.container;
import std.range;
import core.stdc.stdlib;

void main() {
  auto N = readln.chomp.to!int;
  int[][] gameOrders;
  gameOrders.length = N;
  foreach(i; N.iota()) {
    gameOrders[i] = readln.split.to!(int[]);
  }

  int days = 0;
  auto ordersPerPlayer = gameOrders.map!(o => o.empty() ? -1 : o[0]).array;
  while(true){

    bool[int] gamedPlayers;
    for(int player=0; player<N; player++) {
      if (ordersPerPlayer[player] == -1) continue;

      if (ordersPerPlayer[ordersPerPlayer[player]-1] == player+1) {
        gamedPlayers[player] = true;
        gamedPlayers[ordersPerPlayer[ordersPerPlayer[player]-1]-1] = true;
      }
    }
    if (gamedPlayers.length == 0) {
      writeln(-1);
      exit(0);
    }
    foreach(player; gamedPlayers.keys) {
      gameOrders[player].popFront();
      ordersPerPlayer[player] = gameOrders[player].empty ? -1 : gameOrders[player][0];
    }
    days++;

    if (!gameOrders.any!(o => !o.empty)) break;
  }

  writeln(days);
}
