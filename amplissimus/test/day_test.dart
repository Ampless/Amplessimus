import 'package:Amplissimus/timetable/timetables.dart';
import 'package:flutter_test/flutter_test.dart';

class DayTestCase {
  String input;
  TTDay expct;
  bool error;

  DayTestCase(this.input, this.expct, this.error);

  void run() {
    TTDay res;
    try {
      res = ttMatchDay(input);
    } catch (e) {
      if (!error) rethrow;
      else return;
    }
    if (error) throw 'No error.';
    if (res != expct) throw '"$input" cannot be matched to $expct';
  }
}

List<DayTestCase> dayTestCases = [
  DayTestCase(null, TTDay.Null, false),
  DayTestCase('', TTDay.Null, false),
  DayTestCase('heute ist MoNtAg', TTDay.Monday, false),
  DayTestCase('beatifufflk MoNNDaY', TTDay.Null, true),
  DayTestCase('wednesday okd okd', TTDay.Wednesday, false),
  DayTestCase('_kEkW_freiTaG', TTDay.Friday, false),
];

void main() {
  group('day', () {
    int i = 1;
    for (var testCase in dayTestCases) test('case ${i++}', testCase.run);
  });
}
