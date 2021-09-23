import std.stdio, std.conv, std.array, std.string, std.algorithm, std.container, std.range, core.stdc.stdlib, std.math, std.typecons, std.numeric, std.traits, std.functional, std.bigint, std.datetime.stopwatch, core.time, core.bitop;
import std.net.curl, std.process, core.thread, std.json;
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

class Resource {
  int type, id;
  long x, y;
  long spawnAt, expiredAt;
  long weight;
  real ratio;

  this(int i, int t, long x, long y, long s, long e, long w) {
    id = i;
    type = t;
    spawnAt = s;
    expiredAt = e;
    weight = w;
    this.x = x;
    this.y = y;
    ratio = 1.0;
  }
}

class Agent {
  int id;
  real x, y;
  long movesUntil;
  long worksUntil;
  real workScore;
  real toX, toY;

  this(int i, real x, real y) {
    this.id = i;
    this.x = x;
    this.y = y;
    workScore = 0;
  }

  bool isBusy(long time) {
    return time < movesUntil || time < worksUntil;
  }
}

class Game {
  string API_BASE = "https://contest.2021-autumn.gbc.tenka1.klab.jp/api/%s/%s";
  string token;

  long now;
  Agent[] agents;
  Resource[int] resources;
  auto harvests = new real[](3);
  
  this(string token, bool dev) {
    this.token = token;
    if (dev) API_BASE = "https://contest.2021-autumn.gbc.tenka1.klab.jp/staging/api/%s/%s";

    foreach(i; 0..5) agents ~= new Agent(i + 1, 0, 0);
  }

  void fetchGameStatus() {
    const res = parseJSON(get(API_BASE.format("game", token)));
    foreach(i, agent; res["agent"].array) {
      agents[i].x = agent["move"][0]["x"].toString.to!real;
      agents[i].y = agent["move"][0]["y"].toString.to!real;
      if (agent["move"].array.length > 1) {
        agents[i].movesUntil = agent["move"][1]["t"].integer;
      }
    }

    bool[int] rids;
    foreach(r; res["resource"].array) {
      const rid = r["id"].integer.to!int;
      rids[rid] = true;

      if (rid in resources) {} else {
        const type = cast(int)(r["type"].str[0] - 'A');
        resources[rid] = new Resource(rid, type, r["x"].integer, r["y"].integer, r["t0"].integer, r["t1"].integer, r["weight"].integer);
      }
    }

    foreach(rid, r; resources) {
      if (!(rid in rids)) resources.remove(rid);
    }

    foreach(owned; res["owned_resource"].array) {
      const type = cast(int)(owned["type"].str[0] - 'A');
      harvests[type] = owned["amount"].toString.to!real;
    }

    now = res["now"].integer;
    harvests.deb;
  }

  void moveAgent(Agent agent, long x, long y) {
    const res = parseJSON(get(API_BASE.format("move", token) ~ "/%s-%s-%s".format(agent.id, x, y)));
    "moved %s to (%s, %s)".format(agent.id, x, y).deb;
  }

  real scoreFor(Resource r) {
    const mx = harvests.maxElement == 0 ? 1 : harvests.maxElement;
    const ratios = harvests.map!(h => 1.1 - h / mx).array;
    return ratios[r.type].pow(3) * r.weight * r.ratio;
  }

  void makeDicision() {
    auto res = resources.values;
    auto scores = res.map!(r => scoreFor(r)).array;

    Tuple!(real, Resource, Agent) action;
    action[0] = 0;

    foreach(i; 0..res.length) {
      auto r = res[i];

      const rScore = scores[i];

      foreach(ag; agents) {
        const dx = ag.x - r.x;
        const dy = ag.y - r.y;
        real dt = (dx*dx + dy*dy).to!real.sqrt * 100.0;
        const timeScore = (r.expiredAt - now).to!real - dt - 5*max(0, r.spawnAt - now - dt);
        if (timeScore < 0.01) continue;

        const totalScore = timeScore * rScore;
        if (ag.workScore < totalScore && action[0] < totalScore) {
          action[0] = totalScore;
          action[1] = r;
          action[2] = ag;
        }
      }
    }

    if (action[0] > 0) {
      auto ag = action[2];
      auto r = action[1];
      moveAgent(ag, r.x, r.y);
      ag.worksUntil = r.expiredAt;
      r.ratio *= 0.8;
      ag.workScore = action[0];
      ag.toX = r.x;
      ag.toY = r.y;
    }
  }
}

void main()
{
  Thread.sleep( dur!("msecs")( 1000 ) );
  auto game = new Game(environment.get("TENKA1_TOKEN"), environment.get("TENKA1_ENV") == "dev");
  game.fetchGameStatus;

  long t = 0;
  while(true) {
    Thread.sleep( dur!("msecs")( 100 ) );
    game.now += 100;

    if ((t = (t + 1) % 10) == 0) game.fetchGameStatus;
    foreach(ag; game.agents) {
      if (ag.worksUntil <= game.now) ag.workScore = 0;
      ag.workScore *= 0.99;
      
      if (ag.toX != real.nan) {
        const d = (ag.toX - ag.x).pow(2) + (ag.toY - ag.y).pow(2);
        if (!d.approxEqual(0.0)) {
          const moveSize = min(1, d.sqrt * 0.1);
          ag.x += (ag.toX - ag.x) * moveSize;
          ag.x += (ag.toY - ag.y) * moveSize;
          ag.x.deb;
        }
      }
    }

    foreach(i; 0..5) game.makeDicision;
  }
}


