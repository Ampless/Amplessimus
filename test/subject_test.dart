import 'package:flutter_test/flutter_test.dart';

import '../lib/langs/language.dart';
import '../lib/langs/german.dart';
import '../lib/subject.dart';

import 'testlib.dart';

testCase subParseTestCase(Language lang, String raw, String out) => () async {
      Language.current = lang;
      expect(realSubject(raw), out);
    };

List<testCase> languageTestCases = [
  subParseTestCase(German(), '1e3', '1Englisch3'),
  subParseTestCase(German(), 'psy_2_69', 'Psychologie_2_69'),
  subParseTestCase(German(), 'Kath', 'Katholische Religion'),
  subParseTestCase(German(), '1337etH', '1337Ethik'),
];

void main() {
  tests(languageTestCases, 'subject');
}
