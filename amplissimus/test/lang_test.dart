import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/langs/language.dart';
import 'package:Amplissimus/timetable/timetables.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testlib.dart';

class LanguageTestCase extends SyncTestCase {
  void Function(Language) func;
  Language lang;

  LanguageTestCase(this.func);

  @override
  void run() {
    func(lang);
  }
}

class LanguageCodeTestCase extends SyncTestCase {
  String code;

  LanguageCodeTestCase(this.code);

  @override
  void run() {
    assert(Language.fromCode(code) != null);
  }
}

List<LanguageTestCase> foreachLangTestCases = [
  LanguageTestCase((lang) {
    for (var day in TTDay.values) lang.ttDayToString(day);
  }),
  LanguageTestCase((lang) {
    assert(Language.fromCode(lang.code) == lang);
  }),
  LanguageTestCase((lang) {
    lang.dsbSubtoTitle(null);
  }),
  LanguageTestCase((lang) {
    lang.dsbSubtoSubtitle(null);
  }),
  LanguageTestCase((lang) {
    lang.dsbSubtoTitle(DsbSubstitution(null, null, null, null, null, false));
  }),
  LanguageTestCase((lang) {
    lang.dsbSubtoSubtitle(DsbSubstitution(null, null, null, null, null, false));
  }),
  LanguageTestCase((lang) {
    lang.dsbSubtoTitle(
        DsbSubstitution('lul', [], 'kek', 'subJEeKE', 'notesnotes', false));
  }),
  LanguageTestCase((lang) {
    lang.dsbSubtoSubtitle(
        DsbSubstitution('lul', [], 'kek', 'subJEeKE', 'notesnotes', false));
  }),
  LanguageTestCase((lang) {
    lang.dsbSubtoTitle(
        DsbSubstitution('lul', [1, 3, 5], 'kek', '1sk1', 'not', false));
  }),
  LanguageTestCase((lang) {
    lang.dsbSubtoSubtitle(
        DsbSubstitution('lul', [1, 3, 5], '---', 'sub', 'not', true));
  }),
];

List<LanguageCodeTestCase> languageCodeTestCases = [
  LanguageCodeTestCase(null),
  LanguageCodeTestCase('none'),
];

void main() {
  group('lang', () {
    for (var i = 0; i < foreachLangTestCases.length; i++)
      for (var lang in Language.all) {
        foreachLangTestCases[i].lang = lang;
        runSyncTest('case ${i + 1} for $lang', foreachLangTestCases[i]);
      }
    for (var testCase in languageCodeTestCases)
      runSyncTest('case 2 for null', testCase);
  });
}
