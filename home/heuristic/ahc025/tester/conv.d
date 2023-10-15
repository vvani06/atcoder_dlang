module home.heuristic.ahc025.tester.conv;

import std;

void main() {
  JSONValue report;
  string executeDateTime = execute(["date", "+%Y%m%d_%H%M%S"], ["TZ": "Asia/Tokyo"]).output.chomp;
  report["execute_datetime"] = executeDateTime;

  foreach(entry; dirEntries("out", SpanMode.shallow).array.sort) {
    if (!entry.to!string.endsWith("_score")) continue;

    auto scoreFile = File(entry, "r");
    int caseId, n, d, q;
    scoreFile.readf!" %d %d %d %d "(caseId, n ,d, q);

    long[] w = scoreFile.readln.chomp.split.map!"a.to!long".array;
    long score;
    scoreFile.readf!"Score = %d"(score);

    JSONValue byCase;
    byCase["caseId"] = caseId;
    byCase["n"] = n;
    byCase["d"] = d;
    byCase["q"] = q;
    byCase["score"] = score;
    report[caseId.to!string] = byCase;
  }
  
  mkdirRecurse("reports");
  File("reports/" ~ executeDateTime ~ ".json", "w").writeln(report.toPrettyString());

  JSONValue totalReport;
  totalReport["reports"] = parseJSON("[]");
  foreach(entry; dirEntries("reports", SpanMode.shallow).array.sort) {
    if (entry.to!string == "reports/total.json") continue;

    totalReport["reports"].array ~= parseJSON(readText(entry));
  }
  File("reports/total.json", "w").writeln(totalReport);
}
