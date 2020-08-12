import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
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

class ExpectTestCase extends TestCase {
  dynamic expct;
  bool error;
  Future<dynamic> Function() tfunc;

  ExpectTestCase(this.tfunc, this.expct, this.error);

  @override
  Future<Null> run() async {
    dynamic res;
    try {
      res = await tfunc();
    } catch (e) {
      if (!error)
        rethrow;
      else
        return;
    }
    if (error) throw '[ETC($tfunc, $expct)] No error.';
    expect(res, expct);
  }
}

void testInit() {
  Prefs.initTest();
  ampDisableLogging();
}

void tests(List<TestCase> testCases, String groupName) {
  group(groupName, () {
    var i = 1;
    for (var testCase in testCases)
      test('case ${i++}', () async {
        testInit();
        await testCase.run();
      });
  });
}
