import 'package:dsbuntis/dsbuntis.dart';
import 'package:Amplessimus/timetables.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testlib.dart';

testCase ttTestCase(
  Future<dynamic> Function() tfunc,
  dynamic expct,
  bool error,
) =>
    () async {
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
    };

final List<TTColumn> ttTest1Input1 = [
  TTColumn([
    TTLesson('Mathe', 'Wolf', 'lostes Fach', false),
    TTLesson(null, null, null, true),
  ], Day.Monday),
  TTColumn([
    TTLesson('Deutsch', 'Rosemann', 'mega lost', false),
    TTLesson(null, null, null, true),
  ], Day.Tuesday),
];

final List<DsbPlan> ttTest1Input2 = [
  DsbPlan(
      Day.Monday,
      [
        DsbSubstitution(null, [1], 'Gnan', 'M', 'Mitbetreuung', false),
      ],
      '13.12.-1'),
  DsbPlan(Day.Tuesday, [], 'drölf'),
];

final List<TTColumn> ttTest1Output = [
  TTColumn([
    TTLesson('Mathe', 'Gnan', 'Mitbetreuung', false),
    TTLesson(null, null, null, true),
  ], Day.Monday),
  TTColumn([
    TTLesson('Deutsch', 'Rosemann', 'mega lost', false),
    TTLesson(null, null, null, true),
  ], Day.Tuesday),
];

final List<testCase> ttTestCases = [
  ttTestCase(() async => ttSubTable(ttTest1Input1, ttTest1Input2),
      ttTest1Output, false),
  ttTestCase(() async {
    ttSaveToPrefs(ttTest1Input1);
    return ttLoadFromPrefs();
  }, ttTest1Input1, false),
  ttTestCase(() async => ttFromJson(null), [], false),
  ttTestCase(() async => ttToJson(null), '[]', false),
];

void main() {
  tests(ttTestCases, 'timetable');
}
