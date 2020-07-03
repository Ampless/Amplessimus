import 'package:Amplissimus/langs/language.dart';
import 'package:Amplissimus/timetable/timetables.dart';
import 'package:flutter_test/flutter_test.dart';

List<void Function(Language)> langTestCases = [
  (lang) {
    for (TTDay day in TTDay.values) lang.ttDayToString(day);
  },
];

void main() {
  group('lang', () {
    for (int i = 0; i < langTestCases.length; i++)
      for (var lang in Language.all)
        test('case ${i + 1} for $lang', () => langTestCases[i](lang));
  });
}
