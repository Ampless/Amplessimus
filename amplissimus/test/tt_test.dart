import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/timetable/timetables.dart';
import 'package:flutter_test/flutter_test.dart';

class TTTestCase {
  dynamic expct;
  bool error;
  Function() tfunc;

  TTTestCase(this.tfunc, this.expct, this.error);

  void run() {
    dynamic res;
    try {
      res = tfunc();
    } catch (e) {
      if (!error)
        rethrow;
      else
        return;
    }
    if (error) throw 'No error.';
    expect(expct.length, res.length);
    for (int i = 0; i < res.length; i++)
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
  TTTestCase(
      () => ttSubTable(ttTest1Input1, ttTest1Input2), ttTest1Output, false),
  TTTestCase(() => ttFromJson(ttToJson(ttTest1Input1)), ttTest1Output, false),
  TTTestCase(() => ttFromJson(null), [], false),
  TTTestCase(() => ttToJson(null), '[]', false),
];

void main() {
  group('timetables', () {
    int i = 1;
    for (var testCase in ttTestCases) test('case ${i++}', testCase.run);
  });
}
