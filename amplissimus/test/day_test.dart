import 'package:Amplissimus/timetable/timetables.dart';
import 'package:flutter_test/flutter_test.dart';

class DayTestCase {
  dynamic input;
  dynamic expct;
  bool error;
  Function tfunc;

  DayTestCase(this.input, this.expct, this.error, {this.tfunc = ttMatchDay});

  void run() {
    dynamic res;
    try {
      res = tfunc(input);
    } catch (e) {
      if (!error)
        rethrow;
      else
        return;
    }
    if (error) throw 'No error.';
    expect(res, expct);
  }
}

List<DayTestCase> dayTestCases = [
  DayTestCase(null, TTDay.Null, false),
  DayTestCase('', TTDay.Null, false),
  DayTestCase('heute ist MoNtAg', TTDay.Monday, false),
  DayTestCase('beatifufflk MoNNDaY', null, true),
  DayTestCase('wednesday okd okd', TTDay.Wednesday, false),
  DayTestCase('_kEkW_freiTaG_llUUULW', TTDay.Friday, false),
  DayTestCase(TTDay.Monday, 0, false, tfunc: ttDayToInt),
  DayTestCase(TTDay.Tuesday, 1, false, tfunc: ttDayToInt),
  DayTestCase(TTDay.Wednesday, 2, false, tfunc: ttDayToInt),
  DayTestCase(TTDay.Thursday, 3, false, tfunc: ttDayToInt),
  DayTestCase(TTDay.Friday, 4, false, tfunc: ttDayToInt),
  DayTestCase(TTDay.Null, -1, false, tfunc: ttDayToInt),
  DayTestCase(null, -1, false, tfunc: ttDayToInt),
  DayTestCase(0, TTDay.Monday, false, tfunc: ttDayFromInt),
  DayTestCase(1, TTDay.Tuesday, false, tfunc: ttDayFromInt),
  DayTestCase(2, TTDay.Wednesday, false, tfunc: ttDayFromInt),
  DayTestCase(3, TTDay.Thursday, false, tfunc: ttDayFromInt),
  DayTestCase(4, TTDay.Friday, false, tfunc: ttDayFromInt),
  DayTestCase(-1, TTDay.Null, false, tfunc: ttDayFromInt),
  DayTestCase(null, TTDay.Null, false, tfunc: ttDayFromInt),
];

void main() {
  group('day', () {
    int i = 1;
    for (var testCase in dayTestCases) test('case ${i++}', testCase.run);
  });
}
