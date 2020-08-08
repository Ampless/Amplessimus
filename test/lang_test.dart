import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/timetable/timetables.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testlib.dart';

class LanguageTestCase extends TestCase {
  void Function(Language) func;

  LanguageTestCase(this.func);

  @override
  Future<Null> run() async {
    for (var lang in Language.all) func(lang);
  }
}

class LanguageCodeTestCase extends TestCase {
  String code;

  LanguageCodeTestCase(this.code);

  @override
  Future<Null> run() async {
    assert(Language.fromCode(code) != null);
  }
}

List<LanguageTestCase> languageTestCases = [
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
  LanguageTestCase((lang) {
    if (lang == null || lang.code != 'de') return;
    expect(lang.dsbSubtoTitle(DsbSubstitution('', [1], '', 'a', '', null)),
        '1. Stunde a');
  }),
  LanguageTestCase((lang) {
    if (lang == null || lang.code != 'en') return;
    expect(lang.dsbSubtoTitle(DsbSubstitution('', [11], '', 'b', '', null)),
        '11th lesson Biology');
  }),
  LanguageTestCase((lang) {
    if (lang == null || lang.code != 'en') return;
    expect(lang.dsbSubtoTitle(DsbSubstitution('', [23], '', 'b', '', null)),
        '23rd lesson Biology');
  }),
];

List<LanguageCodeTestCase> languageCodeTestCases = [
  LanguageCodeTestCase(null),
  LanguageCodeTestCase('none'),
];

void main() {
  runTests(languageTestCases, 'lang');
  runTests(languageCodeTestCases, 'lang code');
}
