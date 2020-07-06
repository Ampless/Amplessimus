import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:flutter_test/flutter_test.dart';

abstract class TestCase {
  Future<Null> run();
}

void runTests(List<TestCase> testCases, String groupName) {
  group(groupName, () {
    var i = 1;
    for (var testCase in testCases)
      test('case ${i++}', () async {
        Prefs.initTestPrefs();
        disableLogging();
        await testCase.run();
      });
  });
}
