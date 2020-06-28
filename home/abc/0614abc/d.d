import std.stdio, std.algorithm, std.conv, std.array, std.string, std.math, std.typecons, std.numeric;

enum PCNT = 10^^6;

bool[PCNT+1] PS;

void prime_init()
{
    PS[] = true;
    PS[0] = false;
    PS[1] = false;
    foreach (i; 2..PCNT+1) {
        if (PS[i]) {
            auto x = i*2;
            while (x <= PCNT) {
                PS[x] = false;
                x += i;
            }
        }
    }
}

void main()
{
    prime_init();
    long[] ps;
    foreach (i, p; PS) if (p) ps ~= i.to!long;

    auto N = readln.chomp.to!int;

    auto AS = new int[](10^^6+1);
    foreach (a; readln.split.to!(int[])) ++AS[a];

    auto F = new bool[](10^^6+1);
    int r;
    foreach (i, a; AS) {
        if (a == 0 || F[i]) continue;
        if (a == 1) ++r;
        void run(size_t i) {
            F[i] = true;
            foreach (p; ps) {
                if (i*p > 10^^6) break;
                if (!F[i*p]) run(i*p);
            }
        }
        run(i);
    }
    writeln(r);
}
