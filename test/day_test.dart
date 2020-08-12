import 'package:Amplessimus/day.dart';

import 'testlib.dart';

class DayTestCase extends ExpectTestCase {
  DayTestCase(input, expct, bool error, [Function tfunc = matchDay])
      : super(() async => tfunc(input), expct, error);
}

List<DayTestCase> dayTestCases = [
  DayTestCase(null, Day.Null, false),
  DayTestCase('', Day.Null, false),
  DayTestCase('_kEkW_freiTaG_llUUULW', Day.Friday, false),
  DayTestCase('FvCkDaY', null, true),
  DayTestCase('Montag', Day.Monday, false),
  DayTestCase('Monday', Day.Monday, false),
  DayTestCase('Pondělí', Day.Monday, false),
  DayTestCase('Dienstag', Day.Tuesday, false),
  DayTestCase('Tuesday', Day.Tuesday, false),
  DayTestCase('Úterý', Day.Tuesday, false),
  DayTestCase('Mittwoch', Day.Wednesday, false),
  DayTestCase('Wednesday', Day.Wednesday, false),
  DayTestCase('Středa', Day.Wednesday, false),
  DayTestCase('Donnerstag', Day.Thursday, false),
  DayTestCase('Thursday', Day.Thursday, false),
  DayTestCase('Čtvrtek', Day.Thursday, false),
  DayTestCase('Freitag', Day.Friday, false),
  DayTestCase('Friday', Day.Friday, false),
  DayTestCase('Pátek', Day.Friday, false),
  DayTestCase(Day.Monday, 0, false, dayToInt),
  DayTestCase(Day.Tuesday, 1, false, dayToInt),
  DayTestCase(Day.Wednesday, 2, false, dayToInt),
  DayTestCase(Day.Thursday, 3, false, dayToInt),
  DayTestCase(Day.Friday, 4, false, dayToInt),
  DayTestCase(Day.Null, -1, false, dayToInt),
  DayTestCase(null, -1, false, dayToInt),
  DayTestCase(0, Day.Monday, false, dayFromInt),
  DayTestCase(1, Day.Tuesday, false, dayFromInt),
  DayTestCase(2, Day.Wednesday, false, dayFromInt),
  DayTestCase(3, Day.Thursday, false, dayFromInt),
  DayTestCase(4, Day.Friday, false, dayFromInt),
  DayTestCase(-1, Day.Null, false, dayFromInt),
  DayTestCase(null, Day.Null, false, dayFromInt),
];

void main() {
  tests(dayTestCases, 'day');
}
