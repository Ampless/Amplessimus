import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:flutter_test/flutter_test.dart';

typedef testCase = Future<Null> Function();

testCase expectTestCase(
  Future<dynamic> Function() tfunc,
  dynamic expct,
  bool error,
) =>
    () async {
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
    };

void testInit() {
  Prefs.initTest();
  ampDisableLogging();
}

void tests(List<testCase> testCases, String groupName) {
  group(groupName, () {
    var i = 1;
    for (var testCase in testCases)
      test('case ${i++}', () async {
        testInit();
        await testCase();
      });
  });
}
