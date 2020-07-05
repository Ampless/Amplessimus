import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/langs/language.dart';
import 'package:Amplissimus/timetable/timetables.dart';
import 'package:flutter_test/flutter_test.dart';

List<void Function(Language)> foreachLangTestCases = [
  (lang) {
    for (TTDay day in TTDay.values) lang.ttDayToString(day);
  },
  (lang) {
    assert(Language.fromCode(lang.code) == lang);
  },
  (lang) {
    lang.dsbSubtoTitle(null);
  },
  (lang) {
    lang.dsbSubtoSubtitle(null);
  },
  (lang) {
    lang.dsbSubtoTitle(DsbSubstitution(null, null, null, null, null, false));
  },
  (lang) {
    lang.dsbSubtoSubtitle(DsbSubstitution(null, null, null, null, null, false));
  },
  (lang) {
    lang.dsbSubtoTitle(
        DsbSubstitution('lul', [], 'kek', 'subJEeKE', 'notesnotes', false));
  },
  (lang) {
    lang.dsbSubtoSubtitle(
        DsbSubstitution('lul', [], 'kek', 'subJEeKE', 'notesnotes', false));
  },
  (lang) {
    lang.dsbSubtoTitle(
        DsbSubstitution('lul', [1, 3, 5], 'kek', '1sk1', 'not', false));
  },
  (lang) {
    lang.dsbSubtoSubtitle(
        DsbSubstitution('lul', [1, 3, 5], '---', 'sub', 'not', true));
  },
];

void main() {
  group('lang', () {
    for (int i = 0; i < foreachLangTestCases.length; i++)
      for (var lang in Language.all)
        test('case ${i + 1} for $lang', () => foreachLangTestCases[i](lang));
    test('case 2 for null', () {
      assert(Language.fromCode(null) != null);
    });
    test('case 2 for none', () {
      assert(Language.fromCode('none') != null);
    });
  });
}
