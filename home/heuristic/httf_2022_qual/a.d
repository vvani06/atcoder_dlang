void main() { runSolver(); }

// ----------------------------------------------

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto K = scan!long;
  auto R = scan!long;
  auto D = scan!long(N * K).chunks(K).array;
  auto UV = scan!long(2 * R).chunks(2).array;

  class Task {
    long id;
    long[] requiredSkills;
    long maxRequirement;

    bool finished;
    bool working;
    Task[] preTasks;

    this(long id, long[] requiredSkills) {
      this.id = id;
      this.requiredSkills = requiredSkills;
      this.maxRequirement = requiredSkills.maxElement;
    }

    void addPreTask(Task preTask) {
      preTasks ~= preTask;
    }

    bool canBeWorked() {
      return preTasks.empty || preTasks.all!"a.finished";
    }

    override string toString() {
      return "Task #%02d %s (%s)".format(
        id,
        requiredSkills,
        finished ? "Finished" : working ? "Working" : "Sleeping"
      );
    }
  }

  class Member {
    long id;
    Task task;

    this(long id) {
      this.id = id;
    }

    long[] assign(Task task) {
      this.task = task;
      task.working = true;
      return [id, task.id];
    }

    bool waiting() {
      return task is null;
    }

    void finish() {
      task.finished = true;
      task.working = false;
      task = null;
    }
  }

  class Tasks {
    Task[] tasks;

    void addDepenency(long u, long v) {
      auto tu = find(u);
      auto tv = find(v);
      tv.addPreTask(tu);
    }

    Task find(long id) {
      return tasks[id];
    }

    this(long[][] requiredSkills, long[][] dependencies) {
      tasks ~= new Task(0, [int.max]);
      foreach(i, rs; requiredSkills) {
        tasks ~= new Task(i + 1, rs);
      }
      foreach(d; dependencies) {
        addDepenency(d[0], d[1]);
      }
    }

    Task select() {
      Task ret = find(0);
      foreach(task; tasks[1..$].filter!"a.canBeWorked && !(a.finished || a.working)") {
        if (ret.maxRequirement <= task.maxRequirement) continue;

        ret = task;
      }
      return ret.id == 0 ? null : ret;
    }
  }

  auto solve() {
    Tasks tasks = new Tasks(D, UV);
    auto members = M.iota.map!(m => new Member(m + 1)).array;

    while(true) {
      long[][] assignments;
      foreach(member; members.filter!"a.waiting") {
        auto task = tasks.select;
        if (task) {
          assignments ~= member.assign(task);
        }
      }

      if (assignments.empty) {
        0.writeln;
      } else {
        "%s %s".writefln(assignments.length, assignments.joiner.toAnswerString);
      }
      stdout.flush();

      auto finishedCount = scan!long;
      if (finishedCount == -1) break;

      foreach(n; 0..finishedCount) {
        auto member = members[scan!long - 1];
        member.finish;
      }
    }
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop;
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug writeln(t); }
alias Point = Tuple!(long, "x", long, "y");
Point invert(Point p) { return Point(p.y, p.x); }
long[] divisors(long n) { long[] ret; for (long i = 1; i * i <= n; i++) { if (n % i == 0) { ret ~= i; if (i * i != n) ret ~= n / i; } } return ret.sort.array; }
bool chmin(T)(ref T a, T b) { if (b < a) { a = b; return true; } else return false; }
bool chmax(T)(ref T a, T b) { if (b > a) { a = b; return true; } else return false; }
string charSort(alias S = "a < b")(string s) { return (cast(char[])((cast(byte[])s).sort!S.array)).to!string; }
ulong comb(ulong a, ulong b) { if (b == 0) {return 1;}else{return comb(a - 1, b - 1) * a / b;}}
string toAnswerString(R)(R r) { return r.map!"a.to!string".joiner(" ").array.to!string; }
void outputForAtCoder(T)(T delegate() fn) {
  static if (is(T == float) || is(T == double) || is(T == real)) "%.16f".writefln(fn());
  else static if (is(T == void)) fn();
  else static if (is(T == string)) fn().writeln;
  else static if (isInputRange!T) {
    static if (!is(string == ElementType!T) && isInputRange!(ElementType!T)) foreach(r; fn()) r.toAnswerString.writeln;
    else foreach(r; fn()) r.writeln;
  }
  else fn().writeln;
}
void runSolver() {
  enum BORDER = "==================================";
  debug { BORDER.writeln; while(true) { "<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
