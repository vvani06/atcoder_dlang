void main(string[] args) {
  args.deb;
  const pg = args[1];

  SysTime[string] watched;
  const files =  [pg~".d", "input/"~pg];
  foreach(f; files) {
    watched[f] = f.timeLastModified;
  }

  auto build() {
    spawnShell("clear", std.stdio.stdin, std.stdio.stdout);
    return spawnShell("dmd -debug -of/tmp/"~pg~"_out "~pg~".d && /tmp/"~pg~"_out < input/"~pg, std.stdio.stdin, std.stdio.stdout);
  }

  auto task = build();
  while(true) {
    Thread.sleep( dur!("msecs")( 100 ) );
    foreach(f; files) {
      const t = f.timeLastModified;
      if (watched[f] != t) {
        watched[f] = t;
        kill(task);
        task = build();
      }
    }
  }
}

// ----------------------------------------------

import std.file;
import std.datetime;
import core.thread, std.process;
import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.functional, core.bitop;

// -----------------------------------------------
