import 'package:dsbuntis/dsbuntis.dart';
import 'package:Amplessimus/langs/language.dart';

import 'testlib.dart';

testCase languageTestCase(void Function(Language) func) => () async {
      for (final lang in Language.all) func(lang);
    };

testCase languageCodeTestCase(String code) => () async {
      assert(Language.fromCode(code) != null);
    };

List<testCase> languageTestCases = [
  languageTestCase((lang) {
    for (final day in Day.values) lang.dayToString(day);
  }),
  languageTestCase((lang) {
    lang.dayToString(null);
  }),
  languageTestCase((lang) {
    assert(Language.fromCode(lang.code) == lang);
  }),
  languageTestCase((lang) {
    lang.dsbSubtoSubtitle(null);
  }),
  languageTestCase((lang) {
    lang.dsbSubtoSubtitle(
        DsbSubstitution(null, null, null, null, null, false, null));
  }),
  languageTestCase((lang) {
    lang.dsbSubtoSubtitle(DsbSubstitution(
        'lul', [], 'kek', 'subJEeKE', 'notesnotes', false, 'subkekk'));
  }),
  languageTestCase((lang) {
    lang.dsbSubtoSubtitle(DsbSubstitution(
        'lul', [1, 3, 5], '---', 'sub', 'not', true, 'zdenek je v prdeli'));
  }),
];

List<testCase> languageCodeTestCases = [
  languageCodeTestCase(null),
  languageCodeTestCase('none'),
];

void main() {
  tests(languageTestCases, 'lang');
  tests(languageCodeTestCases, 'lang code');
}
