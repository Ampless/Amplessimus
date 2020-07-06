import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:flutter_test/flutter_test.dart';

abstract class TestCase {
  Future<Null> run();
}

class GenericTestCase extends TestCase {
  Future<Null> Function() func;

  GenericTestCase(this.func);

  @override
  Future<Null> run() => func();
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
