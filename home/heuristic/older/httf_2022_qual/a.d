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

  struct Skills {
    long[] skills;
    real baratsuki = 0;
    long specifiedAt;
    real specifiedLevel = 0;
    long maxElement;

    this(long[] skills) {
      this.skills = skills.dup;

      const real avg = skills.sum.to!real / skills.length;
      baratsuki += skills.map!(s => pow(s.to!real - avg, 2)).sum;
      maxElement = skills.maxElement;
    }

    long maxDiff(Skills other) {
      return skills.length.iota.map!(i => (skills[i] - other.skills[i]).abs).maxElement;
    }
  }

  class Task {
    long id;
    Skills requirement;

    bool finished;
    bool working;

    Task[] preTasks;
    Task[] sufTasks;
    long depth;
    long dependee;
    bool[long] resolves;

    this(long id, long[] requiredSkills) {
      this.id = id;
      this.requirement = Skills(requiredSkills);
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

      depth = 0;
      foreach(preTask; preTasks) {
        depth = max(depth, preTask.calcDepth + 1);
      }

      return depth;
    }

    void calcDependee() {
      foreach(sufTask; sufTasks) {
        resolves[sufTask.id] = true;
        foreach(r; sufTask.resolves.keys) resolves[r] = true;
      }
      dependee += resolves.length;
      // "#s %s".writefln(this);
    }

    override string toString() {
      return "Task #%02d %s (%s) <depth: %s, depends: %s>".format(
        id,
        requirement,
        finished ? "Finished" : working ? "Working" : "Sleeping",
        depth,
        dependee
      );
    }
  }

  class Member {
    long id;
    Skills skills;

    long dayWorkedOn;
    Task task;
    long nextSkillId;

    this(long id) {
      this.id = id;
      skills = Skills(new long[](K));
    }

    long[] assign(Task task) {
      this.task = task;
      task.working = true;
      dayWorkedOn = day;
      nextSkillId %= K;
      // "#s %s".writefln(task);
      return [id, task.id];
    }

    bool waiting() {
      return task is null;
    }

    long estimate(Task task) {
      return skills.maxDiff(task.requirement);
    }

    void finish() {
      task.finished = true;
      task.working = false;

      const workingDays = day - dayWorkedOn;
      foreach(i; 0..K) {
        skills.skills[i].chmax(task.requirement.skills[i] - workingDays);
      }
      "#s %s %s".writefln(id, skills.skills.toAnswerString);

      task = null;
    }
  }

  class Tasks {
    Member[] members;
    Task[] tasks;

    void addDepenency(long u, long v) {
      auto tu = find(u);
      auto tv = find(v);
      tv.addPreTask(tu);
    }

    Task find(long id) {
      return tasks[id - 1];
    }

    this(long[][] requiredSkills, long[][] dependencies, Member[] members) {
      this.members = members;
      foreach(i, rs; requiredSkills) {
        tasks ~= new Task(i + 1, rs);
      }
      foreach(d; dependencies) addDepenency(d[0], d[1]);
      foreach(t; tasks) t.calcDepth();
      foreach(t; tasks.dup.sort!"a.depth > b.depth") t.calcDependee();
    }

    long priority(Task task) {
      if (task.id == 0) return -1;
      Skills req = task.requirement;

      if (day < 1) {
        return req.specifiedLevel.to!long;
      } else {
        return (task.dependee*100) + (req.maxElement^^2);
      }
    }

    auto list() {
      return tasks
        .filter!"a.canBeWorked && !(a.finished || a.working)"
        .array
        .sort!((a, b) => priority(a) > priority(b));
    }
  }

  auto solve() {
    auto members = M.iota.map!(m => new Member(m + 1)).array;
    Tasks tasks = new Tasks(D, UV, members);

    while(true) {
      long[][] assignments;
      foreach(task; tasks.list) {
        // auto waiters = members.filter!"a.waiting".array.randomShuffle;
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
