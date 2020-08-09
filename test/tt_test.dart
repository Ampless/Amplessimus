import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/timetable/timetables.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testlib.dart';

class TTTestCase extends TestCase {
  dynamic expct;
  bool error;
  Future<dynamic> Function() tfunc;

  TTTestCase(this.tfunc, this.expct, this.error);

  @override
  Future<Null> run() async {
    dynamic res;
    try {
      res = await tfunc();
    } catch (e) {
      if (!error)
        rethrow;
      else
        return;
    }
    if (error) throw 'No error.';
    expect(res.length, expct.length);
    for (var i = 0; i < res.length; i++)
      expect(res[i].toString(), expct[i].toString());
  }
}

final List<TTColumn> ttTest1Input1 = [
  TTColumn([
    TTLesson('Mathe', 'Wolf', 'lostes Fach', false),
    TTLesson(null, null, null, true),
  ], TTDay.Monday),
  TTColumn([
    TTLesson('Deutsch', 'Rosemann', 'mega lost', false),
    TTLesson(null, null, null, true),
  ], TTDay.Tuesday),
];

final List<DsbPlan> ttTest1Input2 = [
  DsbPlan(
      TTDay.Monday,
      [
        DsbSubstitution(null, [1], 'Gnan', 'M', 'Mitbetreuung', false),
      ],
      '13.12.-1'),
  DsbPlan(TTDay.Tuesday, [], 'drölf'),
];

final List<TTColumn> ttTest1Output = [
  TTColumn([
    TTLesson('Mathe', 'Gnan', 'Mitbetreuung', false),
    TTLesson(null, null, null, true),
  ], TTDay.Monday),
  TTColumn([
    TTLesson('Deutsch', 'Rosemann', 'mega lost', false),
    TTLesson(null, null, null, true),
  ], TTDay.Tuesday),
];

final List<TTTestCase> ttTestCases = [
  TTTestCase(() async => ttSubTable(ttTest1Input1, ttTest1Input2),
      ttTest1Output, false),
  TTTestCase(() async {
    ttSaveToPrefs(ttTest1Input1);
    await Prefs.waitForMutex();
    return ttLoadFromPrefs();
  }, ttTest1Output, false),
  TTTestCase(() async => ttFromJson(null), [], false),
  TTTestCase(() async => ttToJson(null), '[]', false),
];

void main() {
  tests(ttTestCases, 'timetable');
}
