void main() { problem(); }

// ----------------------------------------------

void problem() {
  auto N = scan!long;
  auto M = scan!long;
  auto K = scan!long;
  auto R = scan!long;
  auto D = scan!long(N * K).chunks(K).array;
  auto UV = scan!long(2 * R).chunks(2).array;

  long day;

  class Task {
    long id;
    long[] requiredSkills;
    long maxRequirement;
    long maxBias;

    bool finished;
    bool working;

    Task[] preTasks;
    Task[] sufTasks;
    long depth;
    long dependee;

    this(long id, long[] requiredSkills) {
      this.id = id;
      this.requiredSkills = requiredSkills;
      this.maxRequirement = requiredSkills.maxElement;
      this.maxBias = requiredSkills.map!(s => (s - requiredSkills.sum / K).abs).maxElement;
      this.depth = -1;
    }

    void addPreTask(Task preTask) {
      preTasks ~= preTask;
      preTask.sufTasks ~= this;
    }

    bool canBeWorked() {
      return preTasks.empty || preTasks.all!"a.finished";
    }

    long calcDepth() {
      if (depth != -1) return depth;

      depth = preTasks.length;
      foreach(preTask; preTasks) {
        depth += preTask.calcDepth;
      }

      return depth;
    }

    void calcDependee() {
      foreach(sufTask; sufTasks) {
        dependee += sufTask.dependee + 1;
      }
    }

    override string toString() {
      return "Task #%02d %s (%s) <depth: %s, depends: %s>".format(
        id,
        requiredSkills,
        finished ? "Finished" : working ? "Working" : "Sleeping",
        depth,
        dependee
      );
    }
  }

  class Member {
    long id;
    long[] skills;

    long dayWorkedOn;
    Task task;

    this(long id) {
      this.id = id;
      skills = new long[](K);
    }

    long[] assign(Task task) {
      this.task = task;
      task.working = true;
      dayWorkedOn = day;
      // deb(id, " <- ", task);
      return [id, task.id];
    }

    bool waiting() {
      return task is null;
    }

    long estimate(Task task) {
      long ret = int.max;
      foreach(i; 0..K) {
        ret = min(ret, max(1, skills[i] - task.requiredSkills[i]));
      }

      return ret;
    }

    void finish() {
      task.finished = true;
      task.working = false;

      const workingDays = day - dayWorkedOn;
      foreach(i; 0..K) {
        skills[i].chmax(task.requiredSkills[i] - workingDays);
      }
      "#s %s %s".writefln(id, skills.toAnswerString);

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
      foreach(d; dependencies) addDepenency(d[0], d[1]);
      foreach(t; tasks) t.calcDepth();
      foreach(t; tasks.dup.sort!"a.depth > b.depth") t.calcDependee();
      // foreach(t; tasks.dup.sort!"a.dependee > b.dependee") t.deb();
    }

    long priority(Task task) {
      if (task.id == 0) return -1;

      return (task.dependee + 1) * 2000 / task.maxRequirement;
    }

    Task select() {
      Task ret = find(0);
      foreach(task; tasks[1..$].filter!"a.canBeWorked && !(a.finished || a.working)") {
        if (priority(ret) >= priority(task)) continue;

        ret = task;
      }

      // priority(ret).deb;
      return ret.id == 0 ? null : ret;
    }
  }

  auto solve() {
    Tasks tasks = new Tasks(D, UV);
    auto members = M.iota.map!(m => new Member(m + 1)).array;

    while(true) {
      long[][] assignments;
      for(auto task = tasks.select; task; task = tasks.select) {
        auto waiters = members.filter!"a.waiting".array;
        if (waiters.empty) break;

        long mi = int.max;
        Member miMember;
        foreach(waiter; waiters) {
          if (mi.chmin(waiter.estimate(task))) {
            miMember = waiter;
          }
        }

        assignments ~= miMember.assign(task);
      }

      if (assignments.empty) {
        0.writeln;
      } else {
        "%s %s".writefln(assignments.length, assignments.joiner.toAnswerString);
      }
      stdout.flush();
      day++;

      members.map!"a.waiting".deb;

      auto finishedCount = scan!long;
      if (finishedCount == -1) break;

      foreach(n; 0..finishedCount) {
        const mid = scan!long;
        auto member = members.find!(m => m.id == mid).front;
        member.finish;
      }
    }
  }

  outputForAtCoder(&solve);
}

// ----------------------------------------------

import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop, std.random;
T[][] combinations(T)(T[] s, in long m) {   if (!m) return [[]];   if (s.empty) return [];   return s[1 .. $].combinations(m - 1).map!(x => s[0] ~ x).array ~ s[1 .. $].combinations(m); }
string scan(){ static string[] ss; while(!ss.length) ss = readln.chomp.split; string res = ss[0]; ss.popFront; return res; }
T scan(T)(){ return scan.to!T; }
T[] scan(T)(long n){ return n.iota.map!(i => scan!T()).array; }
void deb(T ...)(T t){ debug { write("#"); writeln(t); }}
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
  enum BORDER = "#==================================";
  debug { BORDER.writeln; while(true) { "#<<< Process time: %s >>>".writefln(benchmark!problem(1)); BORDER.writeln; } }
  else problem();
}
enum YESNO = [true: "Yes", false: "No"];

// -----------------------------------------------
