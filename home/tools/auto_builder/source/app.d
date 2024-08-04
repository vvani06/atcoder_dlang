import std.stdio;
import std.path;
import core.thread, std.process;
import std.conv, std.array, std.string, std.algorithm, std.container, std.range;
import fswatch;

void main()
{
  auto build(string pg) {
    auto status = wait(spawnShell("clear; echo BUILD "~pg~"; ldmd2 -O -debug -of/tmp/"~pg~"_out "~pg~".d", std.stdio.stdin, std.stdio.stdout));
    return status == 0 ? spawnProcess("/tmp/"~pg~"_out", File("input/"~pg), std.stdio.stdout) : null;
  }
  auto stop(ref Pid task) {
    if (task is null) return;

    import core.sys.posix.signal : SIGKILL;
    kill(task, SIGKILL);
    task = null;
  }

  enum long WAIT_LIMIT_MS = 10_000;

  Pid task;
  long elapsed;
  auto watcher = FileWatch("./", true);
  while(true) {
    Thread.sleep(500.msecs);
    elapsed += 500;
    if (elapsed >= WAIT_LIMIT_MS) stop(task);

    auto events = watcher.getEvents();
    if (events.empty || events[$ - 1].type != FileChangeEventType.modify) continue;

    auto event = events[$ - 1];
    const path = event.path;
    const pg = path.baseName.stripExtension;
    stop(task);
    task = build(pg);
    elapsed = 0;
  }
}
