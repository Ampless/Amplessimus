import 'package:dsbuntis/dsbuntis.dart';
import 'package:amplessimus/langs/language.dart';

import 'testlib.dart';

testCase languageTestCase(Function(Language) func) => () async {
      Language.all.map((e) => func(e));
    };

List<testCase> languageTestCases = [
  languageTestCase((lang) => Day.values.map((e) => lang.dayToString(e))),
  languageTestCase((lang) => testAssert(Language.fromCode(lang.code) == lang)),
  languageTestCase((lang) => lang.dsbSubtoSubtitle(Substitution(
      'lul', -1, 'kek', 'subJEeKE', 'notesnotes', false, 'subkekk'))),
  languageTestCase((lang) => lang.dsbSubtoSubtitle(Substitution(
      'lul', 42, '---', 'sub', 'not', true, 'zdenek je v prdeli'))),
];

void main() {
  tests(languageTestCases, 'lang');
}
