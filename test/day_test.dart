import 'package:Amplessimus/timetable/timetables.dart';

import 'testlib.dart';

class DayTestCase extends ExpectTestCase {
  DayTestCase(input, expct, bool error, [Function tfunc = ttMatchDay])
      : super(() async => tfunc(input), expct, error);
}

List<DayTestCase> dayTestCases = [
  DayTestCase(null, TTDay.Null, false),
  DayTestCase('', TTDay.Null, false),
  DayTestCase('_kEkW_freiTaG_llUUULW', TTDay.Friday, false),
  DayTestCase('FvCkDaY', null, true),
  DayTestCase('Montag', TTDay.Monday, false),
  DayTestCase('Monday', TTDay.Monday, false),
  DayTestCase('Pondělí', TTDay.Monday, false),
  DayTestCase('Dienstag', TTDay.Tuesday, false),
  DayTestCase('Tuesday', TTDay.Tuesday, false),
  DayTestCase('Úterý', TTDay.Tuesday, false),
  DayTestCase('Mittwoch', TTDay.Wednesday, false),
  DayTestCase('Wednesday', TTDay.Wednesday, false),
  DayTestCase('Středa', TTDay.Wednesday, false),
  DayTestCase('Donnerstag', TTDay.Thursday, false),
  DayTestCase('Thursday', TTDay.Thursday, false),
  DayTestCase('Čtvrtek', TTDay.Thursday, false),
  DayTestCase('Freitag', TTDay.Friday, false),
  DayTestCase('Friday', TTDay.Friday, false),
  DayTestCase('Pátek', TTDay.Friday, false),
  DayTestCase(TTDay.Monday, 0, false, ttDayToInt),
  DayTestCase(TTDay.Tuesday, 1, false, ttDayToInt),
  DayTestCase(TTDay.Wednesday, 2, false, ttDayToInt),
  DayTestCase(TTDay.Thursday, 3, false, ttDayToInt),
  DayTestCase(TTDay.Friday, 4, false, ttDayToInt),
  DayTestCase(TTDay.Null, -1, false, ttDayToInt),
  DayTestCase(null, -1, false, ttDayToInt),
  DayTestCase(0, TTDay.Monday, false, ttDayFromInt),
  DayTestCase(1, TTDay.Tuesday, false, ttDayFromInt),
  DayTestCase(2, TTDay.Wednesday, false, ttDayFromInt),
  DayTestCase(3, TTDay.Thursday, false, ttDayFromInt),
  DayTestCase(4, TTDay.Friday, false, ttDayFromInt),
  DayTestCase(-1, TTDay.Null, false, ttDayFromInt),
  DayTestCase(null, TTDay.Null, false, ttDayFromInt),
];

void main() {
  tests(dayTestCases, 'day');
}
