import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/timetable/timetables.dart';
import 'package:flutter_test/flutter_test.dart';

class TTTestCase {
  List<TTColumn> inpt1;
  List<DsbPlan> inpt2;
  List<TTColumn> expct;
  bool error;
  Function tfunc;

  TTTestCase(this.inpt1, this.inpt2, this.expct, this.error,
      {this.tfunc = ttSubTable});

  void run() {
    List<TTColumn> res;
    try {
      res = tfunc(inpt1, inpt2);
    } catch (e) {
      if (!error)
        rethrow;
      else
        return;
    }
    if (error) throw 'No error.';
    bool fail = false;
    if (expct.length == res.length) {
      for (int i = 0; i < res.length; i++)
        if (res[i].toString() != expct[i].toString()) fail = true;
    } else fail = true;
    if(fail) throw 'got:      $res\nexpected: $expct';
  }
}

final List<TTTestCase> ttTestCases = [
  TTTestCase([
    TTColumn([
      TTLesson('Mathe', 'Wolf', 'lostes Fach', false),
      TTLesson(null, null, null, true),
    ], TTDay.Monday),
    TTColumn([
      TTLesson('Deutsch', 'Rosemann', 'mega lost', false),
      TTLesson(null, null, null, true),
    ], TTDay.Tuesday),
  ], [
    DsbPlan(
        TTDay.Monday,
        [
          DsbSubstitution(null, [1], 'Gnan', 'M', 'Mitbetreuung', false),
        ],
        '13.12.-1'),
    DsbPlan(TTDay.Tuesday, [], 'drölf'),
  ], [
    TTColumn([
      TTLesson('Mathe', 'Gnan', 'Mitbetreuung', false),
      TTLesson(null, null, null, true),
    ], TTDay.Monday),
    TTColumn([
      TTLesson('Deutsch', 'Rosemann', 'mega lost', false),
      TTLesson(null, null, null, true),
    ], TTDay.Tuesday),
  ], false),
];

void main() {
  group('timetables', () {
    int i = 1;
    for (var testCase in ttTestCases) test('case ${i++}', testCase.run);
  });
}
